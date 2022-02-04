#!/bin/bash

set -e

if [ -f "/usr/lib/check_mk_agent/local/mk_postgres_replication.py" ]; then
    /bin/bash /write_pg_replication_checker_conf.sh

    if [ -f /var/lib/postgresql/data/postgresql.conf ] ; then
        /update_postgresql_conf.sh /var/lib/postgresql/data/postgresql.conf
    fi
fi

xinetd
echo "Preparing to launch PostgreSQL..."
docker-entrypoint.sh postgres
