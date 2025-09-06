#!/usr/bin/env bash
set -euo pipefail
echo "Running ETL scripts against MySQL/MariaDB..."

# Adjust these variables if needed
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-password}"  # use env var DB_PASS for production

# If using docker-compose with a mariadb service and mounted volume,
# ensure that your CSVs are in the mounted folder expected by the SQL scripts.

mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" < sql/etl.sql
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" < sql/json.sql

echo "ETL SQL executed. Check the DB and OUTFILE locations for JSON exports."
