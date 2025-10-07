# Tenant Onboarding Flow (Infra Phase)

## Implemented (Infra)
- **Tenant registry** table: `public.tenants` in `loggerhub_core_db`.
- **Demo tenant** auto-inserted during initialization.
- **Schema template** stored at `infra/postgres/templates/tenant_schema_template.sql`.
- **Postgres init scripts** (`00-create-dbs.sh`, `01-create-public-tenants.sh`) execute automatically on first run.

## Planned (Next Phases)
1. **API Gateway**
   - Handles `/tenants/signup`
   - Inserts new row in `public.tenants`
   - Publishes `TENANT_CREATED` event via Redis
2. **Processor Service**
   - Listens for `TENANT_CREATED`
   - Reads SQL template → creates tenant schema in `loggerhub_processor_db`
3. **Search Service**
   - Mirrors schema or creates index in OpenSearch
4. **MinIO Bucket**
   - `/logs/<tenant_slug>/` auto-created
5. **OpenSearch Index**
   - `logs_<tenant_slug>` initialized for full-text queries
