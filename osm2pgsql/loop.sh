#!/bin/bash

if [ ! -v OSM2PGSQL_CACHE ]; then
	echo "ERROR: OSM2PGSQL_CACHE is not set."
	exit 1
fi

set -e

LOOP_DELAY=600
OSM_PATH="/osmpbf/osm.pbf"
OSM_REPL_PATH="/tmp/osm.diffs.pbf"
OSM_REPL_SEQ="/tmp/osm.seq"

REPL_USER=repl
REPL_PUB=osm_pub
REPL_SUB=osm_sub

REPL_TABLES="planet_osm_point, planet_osm_line, planet_osm_roads, planet_osm_polygon"
OSM2PGSQL_OPTIONS="-G -S /openstreetmap-carto.style --hstore --tag-transform-script /openstreetmap-carto.lua -C ${OSM2PGSQL_CACHE} --slim --database $POSTGRES_DB -H $POSTGRES_MASTER_HOST -U $POSTGRES_MASTER_USER -P $POSTGRES_MASTER_PORT"

if [[ $FLAT_NODES == 1 ]]; then
	OSM2PGSQL_OPTIONS=$OSM2PGSQL_OPTIONS" --flat-nodes /flatnodes/flat.nodes"
fi

postgres_ready() {
	wait-for-it -t 0 $POSTGRES_MASTER_HOST:$POSTGRES_MASTER_PORT
	while ! psql -p $POSTGRES_MASTER_PORT -h $POSTGRES_MASTER_HOST $POSTGRES_DB $POSTGRES_MASTER_USER &> /dev/null; do
		echo "PostgreSQL is starting up. Waiting..."
		sleep 1
	done
	echo "PostgreSQL master ready"
}

initialize() {
	echo "OSM PBF does not exist, fetching..."
	wget -q -O $OSM_PATH $PLANET_SOURCE

	osm2pgsql --create $OSM2PGSQL_OPTIONS $OSM_PATH

	# To able to propagate updates and deletes later, the tables need replica indentities.
	ATABS=""
	IFS=", " read -ra RT <<< "$REPL_TABLES" # Unpack list of tables into array
	for t in "${RT[@]}"; do
		ATABS="$ATABS ALTER TABLE $t ADD COLUMN id SERIAL PRIMARY KEY; ALTER TABLE $t REPLICA IDENTITY DEFAULT;"
	done

	psql -c "
		CREATE PUBLICATION osm_pub FOR TABLE $REPL_TABLES;
		GRANT SELECT, UPDATE ON $REPL_TABLES TO $REPL_USER;
		GRANT SELECT ON $REPL_TABLES TO osm_readonly;
		$ATABS
	" -h $POSTGRES_MASTER_HOST -p $POSTGRES_MASTER_PORT $POSTGRES_DB $POSTGRES_MASTER_USER

	echo "Initial import completed."
}

update() {
	echo "Preparing for update"

	rm $OSM_REPL_PATH 2>/dev/null || true

	PYOSMIUM_FLAGS=""
	if [[ -e $OSM_REPL_SEQ ]]; then
		echo "Fetching patches based on replication sequence"
	else
		echo "Fetching patches based on OSM file"
		PYOSMIUM_FLAGS="$PYOSMIUM_FLAGS -O $OSM_PATH"
	fi

	if pyosmium-get-changes --server $PLANET_REPL_URL -v --sequence-file $OSM_REPL_SEQ -o $OSM_REPL_PATH $PYOSMIUM_FLAGS ; then
		echo "Diff has been fetched, proceeding to import"
		osm2pgsql --append $OSM2PGSQL_OPTIONS $OSM_REPL_PATH
	else
		echo "Already at latest version. Nothing to update."
	fi
}

FIRST_RUN=1

printf "$POSTGRES_MASTER_HOST:$POSTGRES_MASTER_PORT:$POSTGRES_DB:$POSTGRES_MASTER_USER:$POSTGRES_MASTER_PASSWORD" > ~/.pgpass
chmod 0600 ~/.pgpass

while [[ 1 ]]; do
	postgres_ready
	if ! psql -A -t -c "SELECT 1 FROM planet_osm_point LIMIT 1;" -h $POSTGRES_MASTER_HOST -p $POSTGRES_MASTER_PORT -d $POSTGRES_DB -U $POSTGRES_MASTER_USER &> /dev/null; then
		initialize
	else
		if [[ $FIRST_RUN -eq 1 ]]; then
			echo "An existing data import has been detected. Will start updating. If you don't wish to do this and instead want to start a new import, stop this container and please make sure that the PostgreSQL data volume has been deleted."
		fi
		update
	fi
	FIRST_RUN=0

	echo "Sleeping for $LOOP_DELAY s"
	sleep $LOOP_DELAY
done
