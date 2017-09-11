#!/usr/bin/env bash

set -e

export VM_NAME=playlist_pal
echo "Setting VM_IP"
export VM_IP=$(hostname -i)
echo "Set VM_IP as ${VM_IP}"

echo "Waiting for database to become available"
/bin/wait-for-it.sh -t 120 ${POSTGRES_HOST}:${POSTGRES_PORT}

/opt/app/bin/playlist_pal $@