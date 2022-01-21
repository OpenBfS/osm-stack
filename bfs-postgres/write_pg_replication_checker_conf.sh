#! /usr/bin/env bash

# Write ~/.pgass and /etc/pg_replication_checker.conf using environment variables.

if [ ! -v POSTGRES_MASTER ] ; then
    POSTGRES_MASTER=0
fi
POSTGRES_MASTER_PORT=${POSTGRES_MASTER_PORT:-5433}

set -euo pipefail

if [[ $POSTGRES_MASTER == 1 ]]; then
    POSTGRES_OSM_PASSWORD=${POSTGRES_OSM_PASSWORD:-""}
fi

PGM=${POSTGRES_MASTER_HOST:-postgres-master}
POSTGRES_DIFF_WARN=${POSTGRES_DIFF_WARN:-31457280}
POSTGRES_DIFF_CRIT=${POSTGRES_DIFF_CRIT:-125829129}

cat <<EOF > /etc/pg_replication_checker.conf
[general]
is_master = $POSTGRES_MASTER

[publisher]
dbname = osm
host = $PGM
user = repl
port = $POSTGRES_MASTER_PORT
password = $POSTGRES_MASTER_REPL_PASSWORD

[subscriber]
dbname = osm

[thresholds]
# 30 MB
max_diff_warn = $POSTGRES_DIFF_WARN
# 120 MB
max_diff_critical = $POSTGRES_DIFF_CRIT
EOF

echo "Updated ~/.pgpass and /etc/pg_replication_checker.conf"
