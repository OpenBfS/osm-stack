#!/bin/bash

set -e

LOOP_DELAY=600
OSM_PATH="/osmpbf/osm.pbf"
OSM_REPL_PATH="/tmp/osm.diffs.pbf"
OSM_REPL_SEQ="/tmp/osm.seq"

REPL_USER=repl
REPL_PUB=osm_pub
REPL_SUB=osm_sub

REPL_TABLES="planet_osm_point, planet_osm_line, planet_osm_roads, planet_osm_polygon"

postgres_ready() {
	wait-for-it -t 0 $POSTGRES_MASTER_HOST:5432
	while ! psql -h $POSTGRES_MASTER_HOST $POSTGRES_DB postgres &> /dev/null; do
		echo "PostgreSQL is starting up. Waiting..."
		sleep 1
	done
	echo "PostgreSQL master ready"

	for follower_host in $POSTGRES_FOLLOWERS; do
		wait-for-it -t 10 $follower_host:5432 || (echo "PostgreSQL follower host '$follower_host' is not reachable. Please make sure that the env variables POSTGRES_FOLLOWERS/SERVICE_HOSTS are configured correctly and the PostgreSQL DBs are up. Aborting operation."; return 1)
	done
}

initialize() {
	echo "OSM PBF does not exist, fetching..."
	wget -q -O $OSM_PATH $OSM_PBF_SOURCE

    OPTIONS="-G -S /openstreetmap-carto.style --hstore --tag-transform-script /openstreetmap-carto.lua -C ${OSM2PGSQL_CACHE}"

	osm2pgsql --slim --create --database $POSTGRES_DB -H $POSTGRES_MASTER_HOST -U $POSTGRES_MASTER_USER $OPTIONS $OSM_PATH

	# To able to propagate updates and deletes later, the tables need replica indentities.
	ATABS=""
	IFS=", " read -ra RT <<< "$REPL_TABLES" # Unpack list of tables into array
	for t in "${RT[@]}"; do
		ATABS="$ATABS ALTER TABLE $t REPLICA IDENTITY FULL;"
	done

	psql -c "
		ALTER PUBLICATION $REPL_PUB ADD TABLE $REPL_TABLES;
		GRANT SELECT ON $REPL_TABLES TO $REPL_USER;
		$ATABS
	" -h $POSTGRES_MASTER_HOST $POSTGRES_DB postgres

	# Prepare and transfer DDL to followers
	pg_dump -t "public.planet_osm_*" --schema-only -h $POSTGRES_MASTER_HOST -U $POSTGRES_MASTER_USER $POSTGRES_DB > /var/lib/db_ddl.sql

	sed -i '/^CREATE TRIGGER/ d' /var/lib/db_ddl.sql # We do not copy the trigger functions to followers.

	for follower_host in $POSTGRES_FOLLOWERS; do
		echo "Copying DDL to $follower_host..."
		psql -f /var/lib/db_ddl.sql -h $follower_host $POSTGRES_DB postgres
		psql -c "ALTER SUBSCRIPTION $REPL_SUB REFRESH PUBLICATION;" -h $follower_host $POSTGRES_DB postgres
	done
}

update() {
	echo "Preparing for update"

	rm $OSM_REPL_PATH || true

	PYOSMIUM_FLAGS=""
	if [[ -e $OSM_REPL_SEQ ]]; then
		echo "Fetching patches based on replication sequence"
	else
		echo "Fetching patches based on OSM file"
		PYOSMIUM_FLAGS="$PYOSMIUM_FLAGS -O $OSM_PATH"
	fi

	if pyosmium-get-changes --server $OSM_PBF_REPL_URL -v --sequence-file $OSM_REPL_SEQ -o $OSM_REPL_PATH $PYOSMIUM_FLAGS ; then
		echo "Diff has been fetched, proceeding to import"
		osm2pgsql --slim --append --database $POSTGRES_DB -H $POSTGRES_MASTER_HOST -U $POSTGRES_MASTER_USER $OSM_REPL_PATH
	else
		echo "Already at latest version. Nothing to update."
	fi
}

while [[ 1 ]]; do
	postgres_ready
	if ! psql -A -t -c "SELECT 1 FROM planet_osm_point LIMIT 1;" -h $POSTGRES_MASTER_HOST $POSTGRES_DB postgres &> /dev/null; then
		initialize
	else
		update
	fi

	echo "Sleeping for $LOOP_DELAY s"
	sleep $LOOP_DELAY
done
