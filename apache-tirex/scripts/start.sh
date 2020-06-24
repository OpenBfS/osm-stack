#!/bin/bash -x

PSQL="psql -d ${DB_NAME} -h ${DB_HOST} -p ${DB_PORT}"
CONTOURS_DUMP=`basename $CONTOURS_URL`
HILLSHADE=`basename $HILLSHADE_URL`

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

# download hillshade data
cd data
wget  --progress=bar:force:noscroll -N ${HILLSHADE_URL}
if [ ! -d hillshade ]; then
    tar xzf ${HILLSHADE}
fi

# wait for database
wait-for-it -t 0 ${DB_HOST}:${DB_PORT}

# create contours database if it doesn't exist
$PSQL -U ${DB_USER} -qtl | cut -d\| -f1 | grep -qw "${DB_NAME_CONTOURS}"
if [ $? ]; then
    cd /srv/osm_basic_pastel_terrain/data
    wget  --progress=bar:force:noscroll -N ${CONTOURS_URL}
    dropdb   -h ${DB_HOST} -p ${DB_PORT} -U ${DB_SUPERUSER} --if-exists ${DB_NAME_CONTOURS}
    createdb -h ${DB_HOST} -p ${DB_PORT} -U ${DB_SUPERUSER} -O ${DB_USER} ${DB_NAME_CONTOURS}
    gunzip -c ${CONTOURS_DUMP} | pg_restore -O -f - | psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_SUPERUSER} -d ${DB_NAME_CONTOURS}
    if [ $? ]; then
        gunzip -c ${CONTOURS_DUMP} | psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_SUPERUSER} -d ${DB_NAME_CONTOURS}
    fi
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

