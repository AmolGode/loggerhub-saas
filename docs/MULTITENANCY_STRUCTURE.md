# Multitenancy Structure (Infra Phase)

LoggerHub uses a **Shared Database, Separate Schemas** model.

## Layout
| Level | Isolation | Description |
|--------|------------|--------------|
| **Database** | Per service | Each microservice has its own Postgres DB: `loggerhub_core_db`, `loggerhub_processor_db`, `loggerhub_search_db`. |
| **Schema** | Per tenant | Each tenant gets its own schema inside the service DB (e.g., `tenant_demo`, `tenant_acme`). |

## Initialization
- Databases and the global `public.tenants` table are created automatically on first container start.  
- Executed by:
  - `00-create-dbs.sh` → creates DBs + role `loggerhub`
  - `01-create-public-tenants.sh` → creates `public.tenants` + demo tenant
- Tenant schema blueprint: `infra/postgres/templates/tenant_schema_template.sql`  
  (used later by Processor/Search services at runtime).

## Registry Table
`public.tenants` (in `loggerhub_core_db`)
| Column | Type | Purpose |
|---------|------|----------|
| `id` | UUID PK | Tenant identifier |
| `slug` | text UNIQUE | Tenant slug |
| `name` | text | Tenant display name |
| `plan` | text | Subscription tier |
| `onboarding_info` | JSONB | Misc metadata |
| `created_at` | timestamptz | Creation timestamp |
