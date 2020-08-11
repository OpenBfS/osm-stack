#!/bin/bash -xe

PGPASSWORD=${DB_PASSWORD}
PSQL="psql -d ${DB_NAME} -h ${DB_HOST} -p ${DB_PORT}"
CONTOURS_DUMP=`basename $CONTOURS_URL`
HILLSHADE=`basename $HILLSHADE_URL`

# https://stackoverflow.com/questions/30220285/getting-the-date-value-from-a-curl-head-command
function last_modified_from_url {
    curl -s -I $1 |
    awk '/Last-Modified/{ date=""; for(i=2;i<=NF;++i) date=(date " " $i); print date;}' |
    xargs -I{} date -d {} +"%s"
}

function db_exists {
    [ "$( $PSQL -U ${DB_USER} -tAc "SELECT 1 FROM pg_database WHERE datname='${1}'" )" = '1' ]
}

function table_exists {
    [ "$( $PSQL -U ${DB_USER} -d ${1} -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '${2}')" )" = 't' ]
}

printf "$DB_HOST:$DB_PORT:$DB_NAME:$DB_USER:$DB_PASSWORD
$DB_HOST:$DB_PORT:$DB_NAME_CONTOURS:$DB_USER:$DB_PASSWORD" > ~/.pgpass
chmod 0600 ~/.pgpass

envsubst < /srv/openstreetmap-carto-de/osmde.env.xml > /srv/openstreetmap-carto-de/osmde.xml
envsubst < /srv/openstreetmap-carto-de/views_osmde/views-lua.env.sql > /srv/openstreetmap-carto-de/views_osmde/views-lua.sql
envsubst < /etc/tirex/renderer/tms/templates/topplusopen.env.conf > /etc/tirex/renderer/tms/topplusopen.conf
envsubst < /srv/osm_basic_pastel_terrain/basicpastel.env.xml     > /srv/osm_basic_pastel_terrain/basicpastel.xml
envsubst < /srv/osm_basic_pastel_terrain/bfs-labels-only.env.xml > /srv/osm_basic_pastel_terrain/bfs-labels-only.xml

# download shapefiles for carto-de
cd /srv/openstreetmap-carto-de/
./scripts/get-shapefiles.py || true

# download shapefiles for osm_basic_pastel_terrain
cd /srv/osm_basic_pastel_terrain
./scripts/get-shapefiles.py || true

# process hillshade data
cd /srv/hillshade
HILLSHADE_DOWNLOAD=false
HILLSHADE_SERVER_TS=$(last_modified_from_url ${HILLSHADE_URL})
if [ -f timestamp ]; then
    echo "former hillshade timestamp found"
    HILLSHADE_CURRENT_TS=`cat timestamp`
    if (( $HILLSHADE_SERVER_TS > $HILLSHADE_CURRENT_TS )); then
        echo "newer hillshade file available!"
        HILLSHADE_DOWNLOAD=true
    fi
fi
if [ ! -d hillshade ]; then
    HILLSHADE_DOWNLOAD=true
fi
if ${HILLSHADE_DOWNLOAD}; then
    echo "downloading hillshades"
    wget  --progress=bar:force:noscroll -N ${HILLSHADE_URL}
    tar xzf ${HILLSHADE}
    ln -sf /srv/hillshade/hillshade /srv/osm_basic_pastel_terrain/data/
    rm -f ${HILLSHADE}
    echo ${HILLSHADE_SERVER_TS} > timestamp
else
    echo "using existing hillshade data"
fi

# wait for database
wait-for-it -t 0 ${DB_HOST}:${DB_PORT}

# create contours database if it doesn't exist
if ! db_exists ${DB_NAME_CONTOURS} || ! table_exists ${DB_NAME_CONTOURS} contours ; then
    cd /srv/osm_basic_pastel_terrain/data
    wget  --progress=bar:force:noscroll -N ${CONTOURS_URL}
    dropdb   -h ${DB_HOST} -p ${DB_PORT} -U ${DB_SUPERUSER} --maintenance-db=${DB_NAME} --if-exists ${DB_NAME_CONTOURS}
    createdb -h ${DB_HOST} -p ${DB_PORT} -U ${DB_SUPERUSER} --maintenance-db=${DB_NAME} -O ${DB_USER} ${DB_NAME_CONTOURS}
    gunzip -c ${CONTOURS_DUMP} | psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_SUPERUSER} -d ${DB_NAME_CONTOURS}
    rm -f ${CONTOURS_DUMP}
fi

# wait for database synchronisation to complete
# "The pg_stat_subscription view will contain one row per subscription for main worker (with null PID if the worker is not running), and additional rows for workers handling the initial data copy of the subscribed tables." -- https://www.postgresql.org/docs/10/monitoring-stats.html
# -> less than two lines in table pg_stat_subscription => initial data copy is done
COUNT=2
while [ $COUNT -ge 2 ];
do
    COUNT=`$PSQL -U ${DB_USER} -qtAX -c 'select count(*) from pg_stat_subscription'`
    sleep 1
done

# wait until tables are available (using planet_osm_line as test for all tables)
COUNT=""
while [ -z $COUNT ];
do
    COUNT=`$PSQL -U ${DB_USER} -qtAX -c "SELECT 1 FROM pg_tables WHERE tablename='planet_osm_line'"`
    sleep 1
done

$PSQL -U ${DB_USER} -c "CREATE INDEX IF NOT EXISTS planet_osm_point_way_idx ON planet_osm_point USING gist (way); CREATE INDEX IF NOT EXISTS planet_osm_roads_way_idx ON planet_osm_roads USING gist (way); CREATE INDEX IF NOT EXISTS planet_osm_line_way_idx ON planet_osm_line USING gist (way); CREATE INDEX IF NOT EXISTS planet_osm_polygon_way_idx ON planet_osm_polygon USING gist (way);"

# initialize styles (idempotent)
$PSQL -U ${DB_USER}        -f /srv/openstreetmap-carto-de/osm_tag2num.sql
$PSQL -U ${DB_SUPERUSER}   -f /srv/openstreetmap-carto-de/views_osmde/views-lua.sql
$PSQL -U ${DB_USER}        -f /srv/openstreetmap-carto-de/contrib/use-upstream-database/view-line.sql
$PSQL -U ${DB_USER}        -f /srv/openstreetmap-carto-de/contrib/use-upstream-database/view-point.sql
$PSQL -U ${DB_USER}        -f /srv/openstreetmap-carto-de/contrib/use-upstream-database/view-polygon.sql
$PSQL -U ${DB_USER}        -f /srv/openstreetmap-carto-de/contrib/use-upstream-database/view-roads.sql

# create table ${DB_TABLE_GERMAN_TILED} if it doesn't exist
COUNT=`$PSQL -U ${DB_USER} -qtAX -c "SELECT 1 FROM pg_tables WHERE tablename='${DB_TABLE_GERMAN_TILED}'"`
if [ -z $COUNT ]; then
    $PSQL -U ${DB_USER} -c "DROP TABLE IF EXISTS ${DB_TABLE_GERMAN_TILED}"
    cd /srv/openstreetmap-carto-de/
    shp2pgsql -s 3857 -cDI shapefiles/german_tiled.shp ${DB_TABLE_GERMAN_TILED} ${DB_NAME} | $PSQL -U ${DB_USER}
fi

service xinetd start
service rsyslog start
service tirex-master start
service tirex-backend-manager start
service apache2 start

tail -F /var/log/syslog

