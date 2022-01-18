#! /usr/bin/env bash

set -euo pipefail

PID=$$
echo $PID > /var/run/start_tomcat.pid

/usr/local/tomcat/bin/catalina.sh run
