#!/bin/bash

set -e

createuser --superuser nominatim
createdb nominatim

psql -d nominatim -c "CREATE EXTENSION postgis; CREATE EXTENSION hstore;"

cat <(head -n -2 /var/lib/postgresql/data/pg_hba.conf) <(echo "
host	all	all	$PGNET	trust
") > /tmp/pg_hba.conf
mv /tmp/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
