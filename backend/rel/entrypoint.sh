#!/usr/bin/env bash

set -e

if [ -z ${ECS_CLUSTERING+x} ]; then

  export VM_NAME=playlist_pal
  echo "Setting VM_IP"
  export VM_IP=$(hostname -i)
  echo "Set VM_IP as ${VM_IP}"

else

  echo "On AWS ECS"
  #/opt/app/bin/playlist_pal command Elixir.PlaylistPal.ReleaseTasks aws_ecs_dns
  #source db_env
  /opt/app/bin/playlist_pal command Elixir.PlaylistPal.ReleaseTasks aws_cluster
  source cluster_env

fi

echo "Waiting for database to become available"
/bin/wait-for-it.sh -t 120 ${POSTGRES_HOST}:${POSTGRES_PORT}

/opt/app/bin/playlist_pal $@