#!/usr/bin/env bash
# demo.sh - run ETL with sample data
set -euo pipefail

echo "Starting demo with sample CSVs..."
docker-compose up -d mariadb
sleep 15
./run_etl.sh
echo "Demo completed. JSON files should be generated inside MariaDB OUTFILE directory."
