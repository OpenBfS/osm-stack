#! /usr/bin/env bash

# Write ~/.pgass and /etc/pg_replication_checker.conf using environment variables.

if [ ! -v POSTGRES_MASTER ] ; then
    POSTGRES_MASTER=0
fi

set -euo pipefail

if [[ $POSTGRES_MASTER != 1 ]]; then
    cat <<EOF > ~/.pgpass
$POSTGRES_MASTER_HOST:5433:osm:osm:$POSTGRES_OSM_PASSWORD
EOF
    chmod 0600 ~/.pgpass
fi

PGM=${POSTGRES_MASTER_HOST:-postgres-master}

cat <<EOF > /etc/pg_replication_checker.conf
[general]
is_master = $POSTGRES_MASTER

[publisher]
dbname = osm
host = $PGM
user = osm 
port = 5432

[subscriber]
dbname = osm

[thresholds]
# 30 MB
max_diff_warn = 31457280
# 120 MB
max_diff_critical = 125829120
EOF

echo "Updated ~/.pgpass and /etc/pg_replication_checker.conf"
