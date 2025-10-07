# Services Overview (Infra Phase)

## Microservices

### 🟢 api_gateway  (Django + DRF)
- Manages tenant registry, auth, plans, and API keys.
- Connects to `loggerhub_core_db`.

### ⚙️ processor_service  (Django + Celery)
- Processes and enriches incoming logs.
- Connects to `loggerhub_processor_db`.
- Responsible for creating tenant schemas dynamically using the SQL template.

### 🔍 search_service  (Django + DRF)
- Provides log search/filter APIs and caching.
- Connects to `loggerhub_search_db`.

### ⚡ ingestion_service  (Go)
- Handles high-throughput log ingestion (10 K req/sec+).
- Pushes messages to Redis queues for async processing.

## Infra Dependencies
| Component | Role |
|------------|------|
| **Redis** | Broker + cache |
| **OpenSearch** | Full-text index |
| **MinIO** | Raw log storage |
| **PostgreSQL** | Structured data |
| **Docker Compose** | Local orchestration |
