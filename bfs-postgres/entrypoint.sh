#!/bin/bash

set -e

/bin/bash /write_pg_replication_checker_conf.sh

if [ -f /var/lib/postgresql/data/postgresql.conf ] ; then
    /update_postgresql_conf.sh /var/lib/postgresql/data/postgresql.conf
fi

xinetd
echo "Preparing to launch PostgreSQL..."
docker-entrypoint.sh postgres
