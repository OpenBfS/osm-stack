#!/bin/bash

set -e

OSM_DB=osm
OSM_USER=osm
REPL_USER=repl

POSTGRES_MASTER_PORT=${POSTGRES_MASTER_PORT:-5433}
POSTGRES_MASTER_REPL_USER=repl

ANYHOST=0.0.0.0/0

DDL_PATH=/tmp/db_ddl.sql

createuser $OSM_USER
createdb -O $OSM_USER $OSM_DB

createuser osm_readonly

psql $OSM_DB -c "
	ALTER USER $OSM_USER PASSWORD '$POSTGRES_OSM_PASSWORD';

	CREATE EXTENSION postgis;
	CREATE EXTENSION hstore;
"

HBA="host    $OSM_DB,contours    $OSM_USER    $ANYHOST    md5
host    osm    osm_readonly    $ANYHOST    trust\n"


if [[ $POSTGRES_MASTER == 1 ]]; then
	psql $OSM_DB postgres -c "
		CREATE ROLE $REPL_USER WITH REPLICATION LOGIN PASSWORD '$POSTGRES_MASTER_REPL_PASSWORD';
	"

	HBA=$HBA"host    $OSM_DB    $REPL_USER    $ANYHOST    md5\n"
else
	psql $OSM_DB -c "
	    CREATE EXTENSION IF NOT EXISTS osml10n CASCADE;
	    ALTER USER $OSM_USER SUPERUSER;
	"
	wait-for-it -t 0 $POSTGRES_MASTER_HOST:$POSTGRES_MASTER_PORT

	while ! PGPASSWORD=$POSTGRES_MASTER_REPL_PASSWORD pg_dump -t planet_osm_point -t planet_osm_line -t planet_osm_roads -t planet_osm_polygon --schema-only -h $POSTGRES_MASTER_HOST -p $POSTGRES_MASTER_PORT -U $POSTGRES_MASTER_REPL_USER $OSM_DB > $DDL_PATH; do
		echo "PostgreSQL master not yet ready. Waiting..."
		sleep 10
	done

	sed -i '/^CREATE TRIGGER/ d' $DDL_PATH # We do not copy trigger functions.
	sed -i '/^GRANT SELECT/ d' $DDL_PATH
	psql -f $DDL_PATH $OSM_DB $OSM_USER
	psql $OSM_DB -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO osm_readonly;"

	echo "Starting logical replication"
	SUBSLOT="osm_sub_`cat /dev/urandom | head -n 2 | shasum | cut -c -10`"
	psql $OSM_DB -c "
		CREATE SUBSCRIPTION osm_sub CONNECTION 'host=$POSTGRES_MASTER_HOST port=$POSTGRES_MASTER_PORT user=$REPL_USER password=$POSTGRES_MASTER_REPL_PASSWORD dbname=$OSM_DB' PUBLICATION osm_pub WITH (slot_name = '$SUBSLOT');
	"
fi

cat <(head -n -2 /var/lib/postgresql/data/pg_hba.conf) <(printf "$HBA") > /tmp/pg_hba.conf
mv /tmp/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
