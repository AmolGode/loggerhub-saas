# LoggerHub – Architecture Overview (Infra Phase)

## Phase 1 Goal
Establish a production-grade, containerized infrastructure foundation for all LoggerHub services.

## Components
| Layer | Tool | Description |
|--------|------|-------------|
| Data Store | PostgreSQL 15 | Multi-DB setup (core, processor, search) |
| Messaging | Redis 7 | Celery broker + event bus |
| Storage | MinIO | Object store for raw logs |
| Search | OpenSearch 2.9 | Index + query engine |
| Orchestration | Docker Compose | Spins up all infra services |
| Networking | `loggerhub_net` | Shared bridge network |
| Persistence | Named volumes | Data durability across runs |

## Database Initialization Flow
1. Container starts with custom Dockerfile.  
2. Executes `/docker-entrypoint-initdb.d/` scripts:  
   - `00-create-dbs.sh` → creates databases & user.  
   - `01-create-public-tenants.sh` → creates global tenant table.  
3. Databases created:  
   - `loggerhub_core_db`  
   - `loggerhub_processor_db`  
   - `loggerhub_search_db`  

## Folder Structure

## 📁 Folder Structure

<details>
<summary>🧠 Root Directory – <code>loggerhub/</code></summary>

- **Purpose:** Contains all backend microservices, infra, and documentation for LoggerHub (SaaS logging platform).  
- **Phases:** Currently at **Phase 1 – Infra Setup ✅**

Contents:
- `/services` – All microservices (Django + Go)
- `/infra` – Docker & infra configuration
- `/docs` – Internal documentation (tech stack, architecture, etc.)
- `/README.md` – Project overview and current progress
</details>

---

<details>
<summary>⚙️ Infrastructure – <code>/infra</code></summary>

- **Purpose:** Contains all configuration and setup files for infra components  
  (Postgres, Redis, MinIO, OpenSearch, Docker Compose, and envs).

Structure:
- `docker-compose.yml` – Main orchestration file  
- **/envs** – Environment variable files for services  
  - `infra.env` – Core infra configs  
  - `api_gateway.env` – Gateway-specific env  
  - `processor_service.env` – Processor configs  
  - `search_service.env` – Search configs  
  - `ingestion_service.env` – Go service env  
- **/postgres** – Postgres DB setup  
  - `Dockerfile` – Custom Postgres build  
  - **/init** – Scripts auto-executed on first startup  
    - `00-create-dbs.sh` – Creates service DBs + user  
    - `01-create-public-tenants.sh` – Creates global `public.tenants` table  
  - **/templates** – Static SQL blueprints used at runtime  
    - `tenant_schema_template.sql` – Template for tenant schema creation  
- **/redis** – Redis placeholder for future config  
- **/minio** – MinIO placeholder (object storage config)  
- **/opensearch** – OpenSearch placeholder (index setup config)
</details>

---

<details>
<summary>🧩 Microservices – <code>/services</code></summary>

- **Purpose:** Each service runs as a separate container with its own database and role.

Structure:
- **/api_gateway** – Django + DRF  
  - Handles tenant management, plans, API keys, authentication  
  - Connects to `loggerhub_core_db`
- **/processor_service** – Django + Celery  
  - Processes incoming logs, enriches data  
  - Dynamically creates tenant schemas in `loggerhub_processor_db`
- **/search_service** – Django + DRF  
  - Exposes log search APIs and caching layer  
  - Connects to `loggerhub_search_db`
- **/ingestion_service** – Go service  
  - Handles high-throughput log ingestion (10K+ req/sec)  
  - Pushes logs to Redis for async processing
</details>

---

<details>
<summary>📚 Documentation – <code>/docs</code></summary>

- **Purpose:** Contains project documentation, updated per phase.

Files:
- `TECH_STACK.md` – Explains chosen infra tools and rationale  
- `MULTITENANCY_STRUCTURE.md` – Describes DB + schema-per-tenant model  
- `SERVICES_OVERVIEW.md` – Overview of all microservices  
- `TENANT_ONBOARDING.md` – Event-driven tenant creation flow  
- `ARCHITECTURE_OVERVIEW.md` – System-level summary (current + future phases)
</details>

---

<details>
<summary>🧾 Miscellaneous</summary>

- **README.md** – Root project summary and phase progress tracker  
- **.gitignore** – To exclude logs, envs, and compiled files  
- *(Optional in future)* `/scripts/` – Deployment or utility scripts
</details>


---

## 🧱 Nginx Layer

### 🎯 Purpose
Nginx acts as a **reverse proxy and static file server** for all Django-based services.  
It isolates HTTP traffic from the application layer and handles:
- Serving static assets (`/static/` and `/media/`)
- Routing API traffic (e.g., `/api/*`) to Django's Gunicorn server
- Simplifying container-to-container communication inside Docker

### ⚙️ How It Works
- Nginx runs in its own container (`infra-nginx`)
- It listens on port `8100` on the host and forwards traffic to the `api_gateway` (port `8000` inside the Docker network)
- Static files are served directly from `/app/staticfiles/` — collected via Django’s `collectstatic`
- Dynamic API routes are proxied to Gunicorn running in the Django container

### 🧩 Why We Use It
- Offloads static serving from Django → better performance
- Acts as a unified entry point for all HTTP traffic
- Allows easy SSL termination and load balancing in future
- Keeps Django containers lightweight and focused on application logic

### 🧭 Example Flow
```text
Browser → Nginx (8100)
        ├── /static/ → Served directly from volume
        └── /api/* → Forwarded to Gunicorn (Django)
