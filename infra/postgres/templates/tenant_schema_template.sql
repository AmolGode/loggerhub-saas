-- loggerhub/infra/postgres/init/tenant_schema_template.sql
-- Template used later (not executed automatically) to create a tenant schema per service.

-- Replace :tenant_schema: with actual tenant name before execution.

CREATE SCHEMA IF NOT EXISTS :tenant_schema: AUTHORIZATION loggerhub;

CREATE TABLE IF NOT EXISTS :tenant_schema:.logs (
    id BIGSERIAL PRIMARY KEY,
    ingest_id UUID,
    timestamp TIMESTAMP WITH TIME ZONE,
    level TEXT,
    message TEXT,
    raw JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

GRANT USAGE ON SCHEMA :tenant_schema: TO loggerhub;
