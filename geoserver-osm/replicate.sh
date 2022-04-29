#!/bin/bash

SSH_HOSTNAME=$MASTER_HOSTNAME
SSH_PORT=$MASTER_PORT
SSH_KEYPATH=/ssh-private-keys/id_root_ed25519
SSH_USER=root

SRC_DATAPATH=/data/geoserver-datadir/
DEST_DATAPATH=/opt/geoserver_data/

SRC_EXTPATH=/data/geoserver-extdir/
DEST_EXTPATH=/opt/additional_libs/

while [[ 1 ]]; do
	wait-for-it -t 0 ${SSH_HOSTNAME}:${SSH_PORT}
	DATA_CHANGES=$(rsync -i -a --exclude 'logs/*' --delete -e "ssh -o StrictHostKeyChecking=no -i $SSH_KEYPATH -p $SSH_PORT" ${SSH_USER}@${SSH_HOSTNAME}:${SRC_DATAPATH} $DEST_DATAPATH)
  EXT_CHANGES=$(rsync -i -a --delete -e "ssh -o StrictHostKeyChecking=no -i $SSH_KEYPATH -p $SSH_PORT" ${SSH_USER}@${SSH_HOSTNAME}:${SRC_EXTPATH} $DEST_EXTPATH)
	echo '$DATA_CHANGES='$DATA_CHANGES
	echo '$EXT_CHANGES='$EXT_CHANGES
	if [[ $DATA_CHANGES != "" ]] || [[ $EXT_CHANGES != "" ]]; then
		echo "New Geoserver configuration has been copied. Reloading..." >> /proc/1/fd/1
		curl -X POST http://${GEOSERVER_USER}:${GEOSERVER_PWD}@localhost:8080/${GEOSERVER_CONTEXT}/rest/reload
	fi

	sleep 60
done
