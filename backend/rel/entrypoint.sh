#!/usr/bin/env bash

set -e

echo "Waiting for database to become available"
/bin/wait-for-it.sh -t 120 ${PG_HOST}:5432

/opt/app/bin/playlist_pal $@