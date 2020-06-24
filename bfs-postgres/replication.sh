#!/bin/bash

set -e

OSM_DB=osm
OSM_USER=osm
REPL_USER=repl

createuser $OSM_USER
createdb -O $OSM_USER $OSM_DB

psql $OSM_DB -c "
	CREATE EXTENSION postgis;
	CREATE EXTENSION hstore;
"

HBA="host	all	all	all	trust\n"

# Preparation of the replication (pub/sub) is not stricly necessary at this point and could be performed later, but that way potential connection errors can pop up before any import processes.
if [[ $POSTGRES_MASTER == 1 ]]; then
	psql $OSM_DB postgres -c "
		CREATE ROLE repl WITH REPLICATION LOGIN;
		CREATE PUBLICATION osm_pub;
	"

#	for allowed_host in $POSTGRES_ALLOWED_HOSTS; do
#		HBA=$HBA"host	all	repl	$allowed_host	trust\n"
#		HBA=$HBA"host	replication	all	$allowed_host	trust\n"
#	done
else
	psql $OSM_DB -c "
	    CREATE EXTENSION IF NOT EXISTS osml10n CASCADE;
	"
	wait-for-it $POSTGRES_MASTER_HOST:5432

	psql $OSM_DB -c "
		CREATE SUBSCRIPTION osm_sub CONNECTION 'host=$POSTGRES_MASTER_HOST port=5432 user=$REPL_USER dbname=$OSM_DB' PUBLICATION osm_pub;
	"
#	HBA=$HBA"host	all	all	$POSTGRES_MASTER_HOST	trust\n"
fi

cat <(head -n -2 /var/lib/postgresql/data/pg_hba.conf) <(echo -e $HBA) > /tmp/pg_hba.conf
mv /tmp/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
