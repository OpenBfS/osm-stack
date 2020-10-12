#! /usr/bin/env bash

PYOSMIUM_UP_TO_DATE=pyosmium-up-to-date
OSMIUM=osmium
JAVA=java
JAR_FILE=${JAR_FILE:-/ors-core/openrouteservice/target/ors-jar-with-dependencies.jar}
PLANET_UPDATE_TMP=/data/osm-data/tmp
PLANET_FILE=/data/osm-data/osm-latest.osm.pbf
POLY_FILE=${POLY_FILE:-/ors-core/germany-100km.poly}
CLIPPED_FILE=/data/osm-data/clipped.osm.pbf
ORS_CONFIG=${ORS_CONFIG:-/ors-core/openrouteservice/src/main/resources/app.config}
LOGGING_CONFIG=${LOGGING_CONFIG:-/ors-core/openrouteservice/src/main/resources/logs/DEFAULT_LOGGING.json}
FAILURE_SLEEP_TIME=${FAILURE_SLEEP_TIME:-300s}
DATA_DIR=/data/openrouteservice

if [ ! -v UPDATE_INTERVAL ] || [ ! -v UPDATE_RECHECK_INTERVAL ] ; then
    echo "ERROR: One of the following variables is not defined: UPDATE_INTERVAL, UPDATE_RECHECK_INTERVAL"
    exit 1
fi

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
    TIMESTAMP=$1
    echo "$TIMESTAMP" > $LAST_UPDATE_FILE
    echo "$TIMESTAMP" > $DATA_DIR/latest/complete
}

function check_update_necessary {
    if [ ! -f "$LAST_UPDATE_FILE" ]; then
        UPDATE_NECESSARY=1
    else
        LAST_UPDATE=`cat $LAST_UPDATE_FILE` || LAST_UPDATE=0
        NOW=$(date +%s)
        DIFF=$(expr $NOW - $LAST_UPDATE)
        UPDATE_NECESSARY=0
        if [[ "$DIFF" -gt $UPDATE_INTERVAL ]]; then
            UPDATE_NECESSARY=1
        fi
    fi
}

function delete_old_data_dirs {
    NOW=$(date +%s)
    for DIR in `find $DATA_DIR/ -maxdepth 1 -type d | grep -v latest | sort -n | head --lines=-1`; do
        # Get age of the directory
        if [[ "$DIR" =~ [0-9]+/?$ ]] ; then
            true
        else
            continue
        fi
	FOUND_TIME=0
        FOUND_TIME=$(cat $DIR/complete) || true
        if [[ "$FOUND_TIME" =~ ^[0-9]+$ ]] ; then
            DIFF=$(expr $NOW - $FOUND_TIME)
        else
            DIFF=$NOW
        fi
        MAX_DIFF=$(( $UPDATE_INTERVAL * 2 ))
        if [ "$DIFF" -lt $MAX_DIFF ] ; then
            continue
        fi
        # Check if there are lockfiles (*.lock)
        LOCKS_COUNT=0
        LOCKS_COUNT=$(ls $DIR/*.lock 2> /dev/null | wc -l) || true
        if [ "$LOCKS_COUNT" -eq 0 ] && [ -f "$DIR/complete" ] ; then
            echo "Deleting $DIR"
            rm -rf "$DIR"
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
    if [ "$UPDATE_NECESSARY" = "0" ]; then
        echo "Sleeping until next update is necessary ..."
    fi
    check_update_necessary
    if [ "$UPDATE_NECESSARY" != "1" ]; then
        sleep $UPDATE_RECHECK_INTERVAL
        continue
    fi
    TIMESTAMP_UPDATE_START=$(date +%s)
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

    CLIPPED_SIZE=$(ls -l $CLIPPED_FILE | tr -s ' ' | cut -d \  -f 5)
    if [ "$CLIPPED_SIZE" -lt 1000 ] ; then
        echo "WARNING: $CLIPPED_FILE is smaller then 1000 bytes. Are you sure that it is located at least partially in your clipping polygon file ($POLY_FILE)"
    fi
    
    # Create symlink if it does not exists. This avoids to change app.config if we use a different extract
    if [ ! -L "/data/osm-data/osm_file.pbf" ] && [ ! -f "/data/osm-data/osm_file.pbf" ]; then
        ln -s $CLIPPED_FILE /data/osm-data/osm_file.pbf
    fi
    
    echo "Running Openrouteservice GraphBuilder"
    # Das doppelte Angeben des Pfades zur Konfigurationsdatei ist erforderlich, da es sonst eine NullPointerException schmeißt (Bug im Openrouteservice).
    $JAVA -Dlog4j.configurationFile=$LOGGING_CONFIG -Dors_app_config=$ORS_CONFIG -jar $JAR_FILE $ORS_CONFIG
    for PROFILE in `jq .ors.services.routing.profiles.active[] $ORS_CONFIG | tr -d '"'` ; do
        if [ ! -f "$DATA_DIR/latest/$PROFILE/nodes" ] ; then
            echo "ERROR: It seems that the ORS import for profile $PROFILE was unsuccessful because the $DATA_DIR/latest/$PROFILE/nodes is missing. Exiting."
	    exit 1
	fi
    done
    write_update_timestamp $TIMESTAMP_UPDATE_START
    echo "Prepare data directory for next update"
    prepare_data_dir_for_next_update
    UPDATE_NECESSARY=0
    sleep 10s
done
