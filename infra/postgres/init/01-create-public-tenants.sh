#!/bin/bash
set -e

echo "🏗️  Creating tenants table in core DB..."

psql -v ON_ERROR_STOP=1 --username "loggerhub" --dbname "loggerhub_core_db" <<-EOSQL
    CREATE SCHEMA IF NOT EXISTS public AUTHORIZATION loggerhub;

    CREATE TABLE IF NOT EXISTS public.tenants (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        slug TEXT UNIQUE NOT NULL,
        name TEXT,
        plan TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
        onboarding_info JSONB DEFAULT '{}'::jsonb
    );

    GRANT ALL PRIVILEGES ON SCHEMA public TO loggerhub;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO loggerhub;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO loggerhub;

    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO loggerhub;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO loggerhub;

    INSERT INTO public.tenants (slug, name, plan)
    VALUES ('tenant_demo', 'Demo Tenant', 'trial')
    ON CONFLICT DO NOTHING;
EOSQL

echo "✅ public.tenants created successfully with proper ownership and privileges!"