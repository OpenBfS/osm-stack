#!/bin/bash

set -e

/write_pg_replication_checker_conf.sh

xinetd
echo "Preparing to launch PostgreSQL..."
docker-entrypoint.sh postgres
