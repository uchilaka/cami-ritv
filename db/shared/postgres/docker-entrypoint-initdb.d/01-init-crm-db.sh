#!/bin/bash
set -e

# This script is intended to be run by the official Postgres Docker image
# during the initial database creation.

if [ -n "$APP_DATABASE_NAME_CRM" ]; then
  # Check if the database already exists
  DB_EXISTS=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -tAc "SELECT 1 FROM pg_database WHERE datname = '$APP_DATABASE_NAME_CRM'")

  if [ "$DB_EXISTS" != "1" ]; then
    echo "Creating CRM database: $APP_DATABASE_NAME_CRM"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
      CREATE DATABASE "$APP_DATABASE_NAME_CRM";
      GRANT ALL PRIVILEGES ON DATABASE "$APP_DATABASE_NAME_CRM" TO "$POSTGRES_USER";
EOSQL
  else
    echo "CRM database $APP_DATABASE_NAME_CRM already exists. Skipping creation."
  fi
else
  echo "APP_DATABASE_NAME_CRM is not set. Skipping secondary database creation."
fi
