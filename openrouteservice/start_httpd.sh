#! /usr/bin/env bash

set -euo pipefail

# Get host IP
# source: https://stackoverflow.com/questions/22944631
export DOCKER_HOST_IP=$(/sbin/ip route|awk '/default/ { print $3 }')

httpd-foreground
