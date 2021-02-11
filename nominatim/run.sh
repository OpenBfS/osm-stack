#! /usr/bin/env bash

set -euo pipefail

# set defaults if these variables are not defined
PLANET_FILE=/osmdata/raw-data.osm.pbf
export NOMINATIM_DIR=/nominatim
export PHOTON_DATA=/data/photon

if [ -z ${UPDATE_INTERVAL+x} ] || [ -z ${UPDATE_RECHECK_INTERVAL+x} ] || [ -z ${DB_NAME+x} ] || [ -z ${DB_HOST+x} ] || [ -z ${DB_PORT+x} ] || [ -z ${DB_USER+x} ] ; then
    echo "WARNING: Any of the following variables is not set, falling back to its default value: UPDATE_INTERVAL, UPDATE_RECHECK_INTERVAL, DB_NAME, DB_HOST, DB_PORT, DB_USER, DB_PASSWORD."
fi

if [ -z $OSM2PGSQL_CACHE ] || [ -z $JAVA_MIN_MEM ] || [ -z $JAVA_MAX_MEM ] || [ -z $DB_PASSWORD ] ; then
    echo "ERROR: One of the following enviroment variables has not been set: OSM2PGSQL_CACHE, JAVA_MIN_MEM, JAVA_MAX_MEM, DB_PASSWORD"
    exit 1
fi

LAST_NOM_UPDATE_FILE=/data/photon/last_nominatim_update
UPDATE_NECESSARY=0

function write_pgpass {
    echo "Writing access credentials for database access to /root/.pgpass"
    echo "${DB_HOST}:${DB_PORT}:${DB_NAME}:${DB_USER}:${DB_PASSWORD}" > /root/.pgpass
    chmod 600 /root/.pgpass
}

function write_update_timestamp {
    TIMESTAMP=$1
    echo "$TIMESTAMP" > $LAST_NOM_UPDATE_FILE
    echo "$TIMESTAMP" > $PHOTON_DATA/latest/complete
}

function check_update_necessary {
    if [ ! -f "$LAST_NOM_UPDATE_FILE" ]; then
        UPDATE_NECESSARY=1
    else
        LAST_UPDATE=`cat $LAST_NOM_UPDATE_FILE` || LAST_UPDATE=0
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
    for DIR in `find $PHOTON_DATA/ -maxdepth 1 -type d | grep -v latest | sort -n | head --lines=-1`; do
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

function ensure_photon_data_dir {
    CURRENT_SEC=$(date +%s)
    # If there is no symlink called "latest", the photon-data volume was deleted and we need to
    # create all directories as if we would start from scratch.
    if [ ! -L "$PHOTON_DATA/latest" ]; then
        echo "It seems that the photon data volume was removed since the last run. Recreating photon data directory and 'latest' symlink."
        mkdir $PHOTON_DATA/$CURRENT_SEC
        ln -s $PHOTON_DATA/$CURRENT_SEC $PHOTON_DATA/latest
    fi
}

function prepare_photon_data_dir {
    if [ ! -L "$PHOTON_DATA/latest" ]; then
        prepare_photon_data_dir
    else
        echo "Deleting existing ElasticSearch data which is likely a leftover of a previous but failed Photon import."
        rm -rf "$PHOTON_DATA/latest/"*
    fi
}

function prepare_photon_for_next_update {
    CURRENT_SEC=$(date +%s)
    mkdir $PHOTON_DATA/$CURRENT_SEC
    # Copy existing data to new directory
    cp -r $PHOTON_DATA/latest/* $PHOTON_DATA/$CURRENT_SEC
    # Change symlink now
    rm $PHOTON_DATA/latest && ln -s $PHOTON_DATA/$CURRENT_SEC $PHOTON_DATA/latest
}

function photon_full_import_from_nominatim {
    echo "Photon: initial Nominatim import"
    /usr/bin/java -Xms$JAVA_MIN_MEM -Xmx$JAVA_MAX_MEM -jar $PHOTON_JAR_NAME -nominatim-import -host $DB_HOST \
        -database $DB_NAME -password $DB_PASSWORD -languages de,en \
        -port $DB_PORT -data-dir $PHOTON_DATA/latest
}

if [ "$#" -ne 0 ]; then
    echo "ERROR: Please call this script without any arguments."
    exit 1
fi

if [ ! -f "$PLANET_FILE" ]; then
    echo "Downloading the .osm.pbf file from $PLANET_SOURCE because it does not exist ..."
    wget --progress=dot:giga -O "$PLANET_FILE" "$PLANET_SOURCE"
else
    echo "Skipping download from $PLANET_SOURCE because $PLANET_FILE exists already."
fi

cd $NOMINATIM_DIR/build

write_pgpass

wait-for-it -t 0 ${DB_HOST}:${DB_PORT}
# Check that user account in the database exists
until PGPASSWORD=${DB_PASSWORD} psql -tAd ${DB_NAME} -h ${DB_HOST} -U ${DB_USER} -c "SELECT 1" ; do
    echo "nominatim-postgres-master is not ready yet. Waiting ..."
    sleep 10
done

FIRST_RUN=1
while true ; do
    # Check if database has already been imported
    if [ "$( psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'import_status')" )" = 't' ] ; then
        IMPORT_PGSQL=$( psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -tAc "SELECT MAX(lastimportdate) FROM import_status" ) || IMPORT_PGSQL=""
        if [ "$IMPORT_PGSQL" != "" ] ; then
            FIRST_RUN=0
        fi
        if [ "$FIRST_RUN" -ne 1 ]; then
            BFS_STATUS=$( psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -tAc "SELECT status FROM bfs_status;") || FIRST_RUN=1
            if [ "$BFS_STATUS" != "1" ]; then
                echo "ERROR: The previous Nominatim import failed. Please remove all tables from the database and restart this Docker container."
                exit 
                FIRST_RUN=1
            fi
        fi
    fi
    if [ -z ${NOMINATIM_THREAD_COUNT:-} ] ; then
        echo "WARNING: NOMINATIM_THREAD_COUNT is not set, using number of CPUs of this system."
        NOMINATIM_THREAD_COUNT=$(nproc)
    fi
    if [ "$FIRST_RUN" -eq 1 ]; then
        TIMESTAMP_UPDATE_START=$(date +%s)
        psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -tAc "CREATE TABLE bfs_status (status INTEGER);" || ( echo "ERROR: Failed to create database table bfs_status. This error usually occurs if the previous import failed."; exit 1)

        echo "Modifying Postgres settings for import:"
        psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -tAc "ALTER SYSTEM SET fsync=off;" || ( echo "ERROR: Failed to set postgres fsync"; exit 1)
        psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -tAc "ALTER SYSTEM SET full_page_writes=off;" || ( echo "ERROR: Failed to set postgres full_page_writes"; exit 1)
        psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -tAc "SELECT pg_reload_conf();" || ( echo "ERROR: Failed to reload postgres"; exit 1)
        wait-for-it -t 0 ${DB_HOST}:${DB_PORT} # paranoia check

        echo "Starting Nominatim import, using $NOMINATIM_THREAD_COUNT threads. This can take two days for a full planet import."
        /usr/bin/php utils/setup.php --osm-file $PLANET_FILE --setup-db --import-data --reverse-only \
            --osm2pgsql-cache $OSM2PGSQL_CACHE --create-functions --create-tables \
            --create-partition-tables --create-partition-functions --load-data --calculate-postcodes \
            --index --create-search-indices --create-country-names --enable-diff-updates \
            --threads $NOMINATIM_THREAD_COUNT && \
            psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -tAc "INSERT INTO bfs_status VALUES (1);"

        echo "Resetting Postgres settings for production:"
        psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -tAc "ALTER SYSTEM RESET ALL;" || ( echo "ERROR: Failed to set reset postgres settings"; exit 1)
        psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -tAc "SELECT pg_reload_conf();" || ( echo "ERROR: Failed to reload postgres"; exit 1)
        wait-for-it -t 0 ${DB_HOST}:${DB_PORT} # paranoia check

        echo "Preparing Photon data directory"
        prepare_photon_data_dir
        photon_full_import_from_nominatim
        echo "Photon: initial Nominatim import"
        /usr/bin/java -Xms$JAVA_MIN_MEM -Xmx$JAVA_MAX_MEM -jar $PHOTON_JAR_NAME -nominatim-import -host $DB_HOST \
            -database $DB_NAME -password $DB_PASSWORD -languages de,en \
            -port $DB_PORT -data-dir $PHOTON_DATA/latest
        echo "Nominatim: Prepare database for updates"
        /usr/bin/php utils/update.php --init-updates
        write_update_timestamp $TIMESTAMP_UPDATE_START
        echo "Prepare Photon database for next update"
        prepare_photon_for_next_update
        FIRST_RUN=0
    else
        ensure_photon_data_dir
        check_update_necessary
        delete_old_data_dirs
        if [ "$UPDATE_NECESSARY" = "1" ]; then
            TIMESTAMP_UPDATE_START=$(date +%s)
            echo "Let Nominatim fetch updates and apply them."
            /usr/bin/php utils/update.php --import-osmosis --no-index
            if [ -d "$PHOTON_DATA/latest/photon_data/elasticsearch" ]; then
                echo "Photon: Fetch updates from Nominatim"
                write_update_timestamp $TIMESTAMP_UPDATE_START
                /usr/bin/java -Xms$JAVA_MIN_MEM -Xmx$JAVA_MAX_MEM -jar $PHOTON_JAR_NAME -nominatim-update -host $DB_HOST \
                    -port $DB_PORT -database $DB_NAME -password $DB_PASSWORD -languages de,en \
                    -data-dir $PHOTON_DATA/latest
            else
                photon_full_import_from_nominatim
                write_update_timestamp $TIMESTAMP_UPDATE_START
            fi
            echo "Prepare Photon database for next update"
            prepare_photon_for_next_update
        fi
    fi
    sleep 60s
done
