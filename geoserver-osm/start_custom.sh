#!/bin/sh

ADDITIONAL_LIBS_DIR=/opt/additional_libs/

# copy additional geoserver libs before starting the tomcat
if [ -d "$ADDITIONAL_LIBS_DIR" ]; then
    find $ADDITIONAL_LIBS_DIR/ -name '*.jar' -exec cp {} $CATALINA_HOME/webapps/geoserver/WEB-INF/lib/ \;
fi

#rename application
mv $CATALINA_HOME/webapps/geoserver $CATALINA_HOME/webapps/${GEOSERVER_CONTEXT}

#wait for postgres
wait_postgresql_ready()
{
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

echo '$GEOSERVER_REPLICA = '$GEOSERVER_REPLICA
#replication ...if SERVICE_HOST
if [ $GEOSERVER_REPLICA -eq 1 ]; then
    echo '....replicate dataDir from MASTER_HOST'
    bash replicate.sh &
fi

wait-for-it -t 0 postgres:5432
wait_postgresql_ready

# start the tomcat
$CATALINA_HOME/bin/catalina.sh run
