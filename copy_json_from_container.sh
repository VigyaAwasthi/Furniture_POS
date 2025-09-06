#!/usr/bin/env bash
# copy_json_from_container.sh
# usage: ./copy_json_from_container.sh <container-name> <remote-path> <local-dest>
set -euo pipefail
container=${1:-mariadb_container}
remote_path=${2:-/var/lib/mysql/POS}
local_dest=${3:-./output}
mkdir -p "$local_dest"
docker cp "$container":"$remote_path/." "$local_dest/"
echo "Copied files to $local_dest"
