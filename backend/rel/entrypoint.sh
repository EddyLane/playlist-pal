#!/usr/bin/env bash

set -e

echo "Setting VM_IP"

if [ -z ${ECS_DNS_POSTGRES+x} ]; then
    export VM_IP=$(ip address | grep 10.32.101 | cut -d" " -f6 | cut -d"/" -f1)
else
    export VM_IP=$(hostname -i)
fi

export VM_NAME=playlist_pal
echo "Set VM_IP as ${VM_IP}"

echo "Waiting for database to become available"
/bin/wait-for-it.sh -t 120 ${POSTGRES_HOST}:${POSTGRES_PORT}

/opt/app/bin/playlist_pal $@