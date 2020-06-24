#! /usr/bin/env bash

# set defaults if these variables are not defined
PLANET_SOURCE=${PLANET_SOURCE:-https://download.geofabrik.de/europe/germany/bremen-latest.osm.pbf}
PLANET_FILE=${PLANET_FILE:-/osmdata/bremen.osm.pbf}
NOMINATIM_DIR=${NOMINATIM_DIR:-/nominatim}
OSM2PGSQL_CACHE=${OSM2PGSQL_CACHE:-4000}
UPDATE_INTERVALL=${UPDATE_INTERVALL:-86400}

set -euo pipefail

LAST_NOM_UPDATE_FILE=/photon-data/last_nominatim_update
UPDATE_NECESSARY=0

function write_update_timestamp {
    date +%s > $LAST_NOM_UPDATE_FILE
}

function check_update_necessary {
    if [ ! -f "$LAST_NOM_UPDATE_FILE" ]; then
        UPDATE_NECESSARY=1
    else
        LAST_UPDATE=`cat $LAST_NOM_UPDATE_FILE` || LAST_UPDATE=0
        NOW=$(date +%s)
        DIFF=$(expr $NOW - $LAST_UPDATE)
        UPDATE_NECESSARY=0
        if [[ "$DIFF" -gt $UPDATE_INTERVALL ]]; then
            UPDATE_NECESSARY=1
        fi
    fi
}

function delete_old_data_dirs {
    for DIR in `find $PHOTON_DATA/ -maxdepth 1 -type d -mtime +2 | grep -v latest | sort -n | head --lines=-1`; do
        # Check if there are lockfiles (*.lock)
        LOCKS_COUNT=$(ls $PHOTON_DATA/$DIR/*.lock 2> /dev/null | wc -l) || true
        if [ "$LOCKS_COUNT" -eq 0 ] && [ -f "$PHOTON_DATA/$DIR/complete" ] ; then
            echo "Deleting $PHOTON_DATA/$DIR"
            rm -rf "$PHOTON_DATA/$DIR"
        fi
    done
}

function prepare_photon_data_dir {
    CURRENT_SEC=$(date +%s)
    # Check if is already a symlink called "latest"
    if [ ! -L "$PHOTON_DATA/latest" ]; then
        mkdir $PHOTON_DATA/$CURRENT_SEC
        ln -s $PHOTON_DATA/$CURRENT_SEC $PHOTON_DATA/latest
    fi
}

function prepare_photon_for_next_update {
    CURRENT_SEC=$(date +%s)
    mkdir $PHOTON_DATA/$CURRENT_SEC
    # Copy existing data to new directory
    cp -r $PHOTON_DATA/latest/* $PHOTON_DATA/$CURRENT_SEC
    touch $PHOTON_DATA/latest/complete
    # Change symlink now
    rm $PHOTON_DATA/latest && ln -s $PHOTON_DATA/$CURRENT_SEC $PHOTON_DATA/latest
}

if [ "$#" -ne 0 ]; then
    echo "ERROR: Please call this script without any arguments."
    exit 1
fi

if [ ! -f "$PLANET_FILE" ]; then
    echo "Downloading the .osm.pbf file because it does not exist ..."
    wget -O "$PLANET_FILE" "$PLANET_SOURCE"
fi

cd $NOMINATIM_DIR/build

wait-for-it -t 0 $POSTGRES_HOST:5432

while true ; do
    # Check if database has already been imported
    IMPORT_STATUS=imported
    IMPORT_PGSQL=$(psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c "COPY import_status TO STDOUT WITH (FORMAT CSV, DELIMITER ',', HEADER FALSE);" | cut -d , -f 1 | sort | tail -n 1) || IMPORT_STATUS=empty
    if [ "$IMPORT_STATUS" != "empty" ]; then
        LAST_IMPORT_DATE=$(date -d "$IMPORT_PGSQL")
    else
        LAST_IMPORT_DATE=""
    fi
    
    if [ "$LAST_IMPORT_DATE" = "" ]; then
        echo "Starting Nominatim import. This can take two days for a full planet import."
        /usr/bin/php utils/setup.php --osm-file $PLANET_FILE --setup-db --import-data --reverse-only \
            --osm2pgsql-cache $OSM2PGSQL_CACHE --create-functions --create-tables \
            --create-partition-tables --create-partition-functions --load-data --calculate-postcodes \
            --index --create-search-indices --create-country-names
        echo "Preparing Photon data directory"
        prepare_photon_data_dir
        echo "Photon: initial Nominatim import"
        /usr/bin/java -Xms4g -Xmx32g -jar $PHOTON_JAR_NAME -nominatim-import -host $POSTGRES_HOST \
            -database $POSTGRES_DB -password strenggeheim -languages de,en \
	    -data-dir $PHOTON_DATA/latest
        echo "Nominatim: Prepare database for updates"
        /usr/bin/php utils/update.php --init-updates
        echo "Prepare Photon database for next update"
        prepare_photon_for_next_update
    else
        check_update_necessary
	delete_old_data_dirs
        if [ "$UPDATE_NECESSARY" = "1" ]; then
            echo "Let Nominatim fetch updates and apply them."
            /usr/bin/php utils/update.php --import-osmosis --no-index
            write_update_timestamp
            touch $PHOTON_DATA/last_nominatim_update
            echo "Photon: Fetch updates from Nominatim"
            /usr/bin/java -Xms4g -Xmx32g -jar $PHOTON_JAR_NAME -nominatim-update -host $POSTGRES_HOST \
            -database $POSTGRES_DB -password strenggeheim -languages de,en \
	    -data-dir $PHOTON_DATA/latest
            echo "Prepare Photon database for next update"
            prepare_photon_for_next_update
        fi
    fi
    sleep 60s
done
