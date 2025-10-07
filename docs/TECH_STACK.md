# LoggerHub – Tech Stack (Infra Phase)

## Core Infrastructure
| Component | Purpose | Notes |
|------------|----------|-------|
| **PostgreSQL 15** | Primary relational datastore | One shared instance with 3 databases (`core`, `processor`, `search`). Schema-per-tenant model. |
| **Redis 7** | Message broker & cache | Used by Celery and for lightweight event passing. |
| **MinIO (RELEASE.2025-09-07)** | S3-compatible object storage | Raw log file storage per tenant (`/logs/<tenant>/`). |
| **OpenSearch 2.9** | Full-text indexing & search | Stores structured log documents for fast queries. |
| **Docker Compose** | Local orchestration | Spins up all infra containers on a shared network `loggerhub_net`. |
| **Networks / Volumes** | Persistence & isolation | Named volumes: `infra_loggerhub_postgres_data`, `infra_loggerhub_redis_data`, etc. |

## Build & Config
- **Custom Postgres Dockerfile**  
  Automatically sets permissions and runs init `.sh` scripts (`00-create-dbs.sh`, `01-create-public-tenants.sh`).
- **Environment Management**  
  All service env files under `infra/envs/` (`infra.env`, `api_gateway.env`, etc.).
- **Versioning**  
  Every infra component runs with explicit image tags for reproducibility.



---

### ⚙️ Makefile (Developer Utility Layer)

#### 🎯 Purpose
The `Makefile` provides short, consistent commands for common Django operations  
without typing full `docker compose` or `manage.py` commands.

Each Django-based service (`api_gateway`, `processor_service`, etc.) has its own `Makefile`.

#### 🧩 Why We Use It
- Keeps developer workflow fast and consistent  
- Avoids memorizing long Docker Compose commands  
- Makes local development easy for new contributors

#### ⚙️ How It Works
The Makefile uses Docker Compose under the hood and passes commands to the correct service container.

Example (`api_gateway/Makefile`):

```makefile
# open Django shell
make shell

# run migrations
make migrate

# collect static files
make static

# install new packages
make install package=<package_name>