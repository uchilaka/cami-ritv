#!/bin/bash
set -e

# This script is intended to be run by the official Postgres Docker image
# during the initial database creation.

if [ -n "$CRM_DATABASE_NAME" ]; then
  # Check if the database already exists
  DB_EXISTS=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -tAc "SELECT 1 FROM pg_database WHERE datname = '$CRM_DATABASE_NAME'")

  if [ "$DB_EXISTS" != "1" ]; then
    echo "Creating CRM database: $CRM_DATABASE_NAME"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
      CREATE DATABASE "$CRM_DATABASE_NAME";
      GRANT ALL PRIVILEGES ON DATABASE "$CRM_DATABASE_NAME" TO "$POSTGRES_USER";
EOSQL
  else
    echo "CRM database $CRM_DATABASE_NAME already exists. Skipping creation."
  fi
else
  echo "CRM_DATABASE_NAME is not set. Skipping secondary database creation."
fi
