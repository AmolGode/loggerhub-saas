#!/bin/bash
set -e

echo "🏗️  Initializing LoggerHub PostgreSQL Databases..."

# Connect using the default superuser (POSTGRES_USER from env)
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'loggerhub') THEN
            CREATE ROLE loggerhub WITH LOGIN PASSWORD '${POSTGRES_PASSWORD}';
            RAISE NOTICE 'Created role: loggerhub';
        ELSE
            RAISE NOTICE 'Role loggerhub already exists, skipping.';
        END IF;
    END
    \$\$;

    CREATE DATABASE loggerhub_core_db OWNER loggerhub;
    CREATE DATABASE loggerhub_processor_db OWNER loggerhub;
    CREATE DATABASE loggerhub_search_db OWNER loggerhub;

    GRANT ALL PRIVILEGES ON DATABASE loggerhub_core_db TO loggerhub;
    GRANT ALL PRIVILEGES ON DATABASE loggerhub_processor_db TO loggerhub;
    GRANT ALL PRIVILEGES ON DATABASE loggerhub_search_db TO loggerhub;
EOSQL

echo "✅ Databases and user created successfully!"
