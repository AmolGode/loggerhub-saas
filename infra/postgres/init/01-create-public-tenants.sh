#!/bin/bash
set -e

echo "🏗️  Creating tenants table in core DB..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "loggerhub_core_db" <<-EOSQL
    CREATE SCHEMA IF NOT EXISTS public;

    CREATE TABLE IF NOT EXISTS public.tenants (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        slug TEXT UNIQUE NOT NULL,
        name TEXT,
        plan TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
        onboarding_info JSONB DEFAULT '{}'
    );

    INSERT INTO public.tenants (slug, name, plan)
    VALUES ('tenant_demo', 'Demo Tenant', 'trial')
    ON CONFLICT DO NOTHING;
EOSQL

echo "✅ public.tenants created successfully!"
