#!/bin/bash

set -e

su postgres -c "createuser --superuser nominatim"
su postgres -c "createdb nominatim"

psql -U postgres -d nominatim -c "CREATE EXTENSION postgis; CREATE EXTENSION hstore;"

cat <(head -n -2 /var/lib/postgresql/data/pg_hba.conf) <(echo "
host	all	all	$PGNET	trust
") > /tmp/pg_hba.conf
mv /tmp/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
