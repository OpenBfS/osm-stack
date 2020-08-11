#!/bin/bash

set -e

xinetd
echo "Preparing to launch PostgreSQL..."
/docker-entrypoint.sh postgres
