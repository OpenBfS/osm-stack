#!/bin/bash

function wait_postgresql_ready {
    FAILED=0
    until psql -d osm -U osm_readonly -h postgres -tAc "SELECT 1" ; do
        if [ "$FAILED" -ne 1 ] ; then
            echo "Waiting until PostgreSQL database is ready ..."
            FAILED=1
        fi
        sleep 10
    done
    until psql -d osm -U osm_readonly -h postgres -tAc "SELECT osm_id FROM planet_osm_polygon LIMIT 1" ; do
        sleep 10
    done
}


if [[ $GEOSERVER_REPLICA == 1 ]]; then
    /replicate.sh &
fi

wait-for-it -t 0 postgres:5432
wait_postgresql_ready

/bin/sh /usr/local/bin/start.sh
