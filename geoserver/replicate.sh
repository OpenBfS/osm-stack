#!/bin/bash

SSH_HOSTNAME=$MASTER_HOSTNAME
SSH_PORT=$MASTER_PORT
SSH_KEYPATH=/ssh-private-keys/id_root_ed25519
SSH_USER=root

SRC_DATAPATH=/data/geoserver/
DEST_DATAPATH=/var/local/geoserver/workspaces/

GEOSERVER_PW=`cat /dev/urandom | head -n 2 | shasum | cut -c -20`

sed -i 's/name="admin.*"/name="admin"\ password="plain:'${GEOSERVER_PW}'"/g' /var/local/geoserver/security/usergroup/default/users.xml

while [[ 1 ]]; do
	wait-for-it -t 0 ${SSH_HOSTNAME}:${SSH_PORT}
	CHANGES=$(rsync -i -a --delete -e "ssh -o StrictHostKeyChecking=no -i $SSH_KEYPATH -p $SSH_PORT" ${SSH_USER}@${SSH_HOSTNAME}:${SRC_DATAPATH} $DEST_DATAPATH)

	if [[ $CHANGES != "" ]]; then
		echo "New Geoserver configuration has been copied. Reloading..."
		curl -X POST http://admin:${GEOSERVER_PW}@localhost:8080/geoserver/rest/reload
	fi

	sleep 60
done


