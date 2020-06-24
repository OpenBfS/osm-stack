#! /usr/bin/env bash

echo "Starting Xinetd"
xinetd

echo "Start run_and_update"
/usr/bin/python3 /run_and_update.py -d /var/data/graphs/ -H $MASTER_HOSTNAME -u root -i /ssh-private-keys/id_root_ed25519 -p $MASTER_PORT -L /lock_directory.py -U /unlock_directory.py -r /openrouteservice-graphs -- /usr/local/tomcat/bin/catalina.sh run
