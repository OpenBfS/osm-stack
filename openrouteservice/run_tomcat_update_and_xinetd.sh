#! /usr/bin/env bash

if [ ! -v ORS_CONFIG_CHANGES ] ; then
    ORS_CONFIG_CHANGES=""
fi

if [ ! -v ORS_LOGGING_CHANGES ] ; then
    ORS_LOGGING_CHANGES=""
fi

set -euo pipefail

if [ "$ORS_CONFIG_CHANGES" != "" ]; then
    echo "Modifying app.config according to environment variable ORS_CONFIG_CHANGES"
    jq "$ORS_CONFIG_CHANGES" /ors-core/openrouteservice/src/main/resources/app.config.orig > /ors-core/openrouteservice/src/main/resources/app.config
fi
if [ "$ORS_LOGGING_CHANGES" != "" ]; then
    SRC=openrouteservice/src/main/resources/logs/PRODUCTION_LOGGING.json.orig
    for FILE in openrouteservice/src/main/resources/logs/PRODUCTION_LOGGING.json openrouteservice/target/classes/logs/PRODUCTION_LOGGING.json openrouteservice/target/ors/WEB-INF/classes/logs/PRODUCTION_LOGGING.json ; do
        echo "Modifying $FILE according to environment variable ORS_LOGGING_CHANGES"
        jq "$ORS_LOGGING_CHANGES" $SRC > $FILE
    done
fi

echo "Starting Xinetd"
xinetd

echo "Start run_and_update"
/usr/bin/python3 /run_and_update.py -d /data/openrouteservice/ -H $MASTER_HOSTNAME -u root -i /ssh-private-keys/id_root_ed25519 -p $MASTER_PORT -L /lock_directory.py -U /unlock_directory.py -r /data/openrouteservice -- /start_tomcat.sh
