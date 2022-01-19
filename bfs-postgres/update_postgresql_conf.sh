#! /usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "ERROR: Wrong usage."
    echo "  Usage: $0 CONFIGURATION_FILE"
    exit 1
fi
CONF_FILE=$1

edit_conf() {
    KEY=$1
    VALUE=$2
    if [ -v KEY ] && [ -v VALUE ] ; then
        sed -i "s/#$KEY.*/$KEY = $VALUE/g" $CONF_FILE
    fi
}

edit_conf wal_level ${POSTGRES_WAL_LEVEL:-logical}
edit_conf wal_compression ${POSTGRES_WAL_COMPRESSION:-on}
edit_conf wal_recycle ${POSTGRES_WAL_RECYCLE:-off}
edit_conf wal_sender_timeout ${POSTGRES_WAL_SENDER_TIMEOUT:-0}
edit_conf shared_buffers ${POSTGRES_SHARED_BUFFERS:-16GB}
edit_conf work_mem ${POSTGRES_WORK_MEM:-128MB}
edit_conf maintenance_work_mem ${POSTGRES_MAINTENANCE_WORK_MEM:-256MB}

cat $CONF_FILE
