#! /usr/bin/env bash

JAVA_OPTS="-Djava.awt.headless=true -server -XX:TargetSurvivorRatio=75 -XX:SurvivorRatio=64 -XX:MaxTenuringThreshold=3 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:ParallelGCThreads=4 -Xms8g -Xmx28g"
PYOSMIUM_UP_TO_DATE=${PYOSMIUM_UP_TO_DATE:-pyosmium-up-to-date}
OSMIUM=${OSMIUM:-osmium}
JAVA=${JAVA:-java}
JAR_FILE=${JAR_FILE:-/ors-core/openrouteservice/target/ors-jar-with-dependencies.jar}
PLANET_UPDATE_TMP=${PLANET_UPDATE_TMP:-/var/data/osm-data/tmp}
PLANET_SOURCE=${PLANET_SOURCE:-https://download.geofabrik.de/europe/germany/baden-wuerttemberg-latest.osm.pbf}
PLANET_FILE=${PLANET_FILE:-/var/data/osm-data/baden-wuerttemberg-latest.osm.pbf}
POLY_FILE=${POLY_FILE:-/ors-core/germany-100km.poly}
CLIPPED_FILE=${CLIPPED_FILE:-/var/data/osm-data/germany-100km.osm.pbf}
ORS_CONFIG=${ORS_CONFIG:-/ors-core/openrouteservice/src/main/resources/app.config}
LOGGING_CONFIG=${LOGGING_CONFIG:-/ors-core/openrouteservice/src/main/resources/logs/DEFAULT_LOGGING.json}
FAILURE_SLEEP_TIME=${FAILURE_SLEEP_TIME:-300s}
DATA_DIR=${DATA_DIR:-/var/data/graphs}
UPDATE_INTERVALL=${UPDATE_INTERVALL:-86400}

set -euo pipefail

# The Path to ORS configuration and logging configuration is retrieved from the arguments
# this script is called with.
if [ "$#" -ne 0 ]; then
    echo "ERROR: Do not call this scripts with arguments!"
    exit 1
fi

LAST_UPDATE_FILE=$DATA_DIR/last_ors_update
UPDATE_NECESSARY=0

function write_update_timestamp {
    date +%s > $LAST_UPDATE_FILE
}

function check_update_necessary {
    if [ ! -f "$LAST_UPDATE_FILE" ]; then
        UPDATE_NECESSARY=1
    else
        LAST_UPDATE=`cat $LAST_UPDATE_FILE` || LAST_UPDATE=0
        NOW=$(date +%s)
        DIFF=$(expr $NOW - $LAST_UPDATE)
        UPDATE_NECESSARY=0
        if [[ "$DIFF" -gt $UPDATE_INTERVALL ]]; then
            UPDATE_NECESSARY=1
        fi
    fi
}

function delete_old_data_dirs {
    for DIR in `find $DATA_DIR/ -maxdepth 1 -type d -mtime +2 | grep -v latest | sort -n | head --lines=-1`; do
        # Check if there are lockfiles (*.lock)
        LOCKS_COUNT=$(ls $DATA_DIR/$DIR/*.lock 2> /dev/null | wc -l) || true
        if [ "$LOCKS_COUNT" -eq 0 ] && [ -f "$DATA_DIR/$DIR/complete" ] ; then
            echo "Deleting $DATA_DIR/$DIR"
            rm -rf "$DATA_DIR/$DIR"
        fi
    done
}

function prepare_data_dir {
    CURRENT_SEC=$(date +%s)
    # Check if is already a symlink called "latest"
    if [ ! -L "$DATA_DIR/latest" ]; then
        mkdir $DATA_DIR/$CURRENT_SEC
        ln -s $DATA_DIR/$CURRENT_SEC $DATA_DIR/latest
    fi
}

function prepare_data_dir_for_next_update {
    CURRENT_SEC=$(date +%s)
    mkdir $DATA_DIR/$CURRENT_SEC
    # Copy existing data to new directory
    touch $DATA_DIR/latest/complete
    # Change symlink now
    rm $DATA_DIR/latest && ln -s $DATA_DIR/$CURRENT_SEC $DATA_DIR/latest
}

mkdir -p $PLANET_UPDATE_TMP

if [ ! -f "$PLANET_FILE" ]; then
    echo "download planet if it does not exist"
    wget --quiet -O "$PLANET_FILE" "$PLANET_SOURCE"
fi

echo "Preparing data directory for graphs"
prepare_data_dir

while true ; do
    check_update_necessary
    if [ "$UPDATE_NECESSARY" != "1" ]; then
        continue
	sleep 60s
    fi
    delete_old_data_dirs
    echo "Updating planet"
    while true; do
        STATUS=0
        "$PYOSMIUM_UP_TO_DATE" -v --tmpdir $PLANET_UPDATE_TMP -s 2000 $PLANET_FILE || STATUS=$?
        if [ "$STATUS" -eq 0 ]; then
            # updates finished
            echo "Planet up to date now."
            break;
        elif [ "$STATUS" -eq 3 ]; then
            # 3 is returned if Pyosmium failed to download diff file (e.g. not published yet on download.geofabrik.de) or network issues
            echo "$PYOSMIUM_UP_TO_DATE returned code $STATUS. This means that there are no new updates available."
            break;
        elif [ "$STATUS" -ne 1 ]; then
            echo "$PYOSMIUM_UP_TO_DATE failed with return code $STATUS"
            exit 1
        fi
        sleep 2s
    done

    echo "Clipping planet"
    "$OSMIUM" extract --overwrite -p "$POLY_FILE" -o "$CLIPPED_FILE" "$PLANET_FILE"
    
    # Create symlink if it does not exists. This avoids to change app.config if we use a different extract
    if [ ! -L "/var/data/osm-data/osm_file.pbf" ] && [ ! -f "/var/data/osm-data/osm_file.pbf" ]; then
        ln -s $CLIPPED_FILE /var/data/osm-data/osm_file.pbf
    fi
    
    echo "Running Openrouteservice GraphBuilder"
    # Das doppelte Angeben des Pfades zur Konfigurationsdatei ist erforderlich, da es sonst eine NullPointerException schmeißt (Bug im Openrouteservice).
    $JAVA $JAVA_OPTS -Dlog4j.configurationFile=$LOGGING_CONFIG -Dors_app_config=$ORS_CONFIG -jar $JAR_FILE $ORS_CONFIG
    write_update_timestamp
    echo "Prepare data directory for next update"
    prepare_data_dir_for_next_update
    sleep 60s
done
