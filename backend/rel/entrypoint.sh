#!/usr/bin/env bash

set -e

if [ -z ${ECS_DNS_POSTGRES+x} ]; then
  export VM_NAME=playlist_pal
  echo "Setting VM_IP"
  export VM_IP=$(hostname -i)
  echo "Set VM_IP as ${VM_IP}"
else
  echo "On AWS ECS"
  echo "NOT SUPPORTED YET. SET ME UP IN entrypoint.sh"
fi

echo "Waiting for database to become available"
/bin/wait-for-it.sh -t 120 ${POSTGRES_HOST}:${POSTGRES_PORT}

/opt/app/bin/playlist_pal $@