#!/usr/bin/env bash

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE pipeline_production;
    GRANT ALL PRIVILEGES ON DATABASE pipeline_production TO "$POSTGRES_USER";
EOSQL
