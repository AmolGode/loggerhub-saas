"""  
doc start  

# Services Overview (Infra Phase 1)

## Overview
Logger Hub is a real-world SaaS-grade logging and analytics system.  
It handles high-throughput log ingestion, processing, indexing, and storage across multiple tenants.  
This document describes the backend service responsibilities and how log data flows through Postgres, OpenSearch, and MinIO.

---

## Microservices

### ⚡ ingestion_service (Go)
- **Purpose:** Entry point for all incoming logs (10k+ logs/sec).
- **Responsibilities:**
  - Receives logs via HTTP `/logs` endpoint.
  - Validates tenant API key.
  - Adds minimal metadata (`timestamp`, `tenant`, `service`, etc.).
  - Pushes the structured JSON payload to Redis queue.
  - Responds immediately (`202 Accepted`).
- **Does not parse** log internals — the client SDK handles that.

---

### ⚙️ processor_service (Django + Celery)
- **Purpose:** Core background worker service that consumes logs from Redis.
- **Responsibilities:**
  - Reads log events from Redis queue.
  - Stores structured log metadata in Postgres.
  - Uploads the raw log file to MinIO.
  - Indexes searchable fields into OpenSearch.
  - Handles retry & fault-tolerance.
- **Connected DB:** `loggerhub_processor_db`.

---

### 🔍 search_service (Django + DRF)
- **Purpose:** Provides APIs for full-text search and log retrieval.
- **Responsibilities:**
  - Query OpenSearch for text search.
  - Fetch metadata from Postgres for pagination and display.
  - Fallback to MinIO for full raw log reconstruction.

---

### 🟢 api_gateway (Django + DRF)
- **Purpose:** Manages tenants, authentication, billing, and API keys.
- **Responsibilities:**
  - Tenant registry in `public.tenants`.
  - Generates per-tenant schemas across services.
  - Broadcasts tenant onboarding events.

---

## Log Flow Summary

SDK → ingestion_service (Go)  
↓  
Redis Queue  
↓  
processor_service (Django + Celery)  
↓  
Postgres  (structured metadata)  
OpenSearch (indexed searchable data)  
MinIO      (raw logs, full content)

---

## SDK Role

- SDKs handle **log parsing per language** (Python, Node, Go, Java, etc.).
- Each SDK sends a **normalized JSON payload**:

{
  "tenant_id": "tenant_a",
  "service": "billing",
  "level": "ERROR",
  "timestamp": "2025-10-10T12:26:36Z",
  "message": "Payment failed due to invalid UUID",
  "full_log": "Traceback (most recent call last): ...",
  "language": "python"
}

- The backend is **language-agnostic**.

---

## Data Storage Strategy

| Storage | Purpose | Example Content |
|----------|----------|-----------------|
| Postgres | Structured, reliable metadata | id, timestamp, service, level, message, raw_path, indexed |
| OpenSearch | Fast full-text search | message, full_log, tenant, service |
| MinIO | Raw, immutable storage | Original JSON file with complete log text |

---

## What’s Stored Where

| Field | Stored In | Description |
|--------|------------|-------------|
| tenant | Postgres | Tenant ID / schema info |
| service | Postgres | Logical source of log |
| level | Postgres | Log level (INFO, ERROR, etc.) |
| timestamp | Postgres | Log creation time |
| message | Postgres | Short summary (first 300–500 chars) |
| full_log | MinIO + OpenSearch | Full log content (stack trace, multiline text) |
| raw_path | Postgres | S3/MinIO path reference |
| indexed | Postgres | Boolean, whether OpenSearch index created |

---

## Why Keep message in Postgres?

Even though OpenSearch and MinIO hold the full log,  
a short `message` field in Postgres provides:
- Fast dashboard loading (no OpenSearch query on refresh)
- Tenant analytics (log counts, retention, billing)
- Pagination and previews
- Relational context with tenants, alerts, or billing tables
- Fail-safe fallback when OpenSearch is down

Postgres = structured metadata  
OpenSearch = search  
MinIO = truth backup

---

## Dashboard Query Strategy

| Action | Source | Description |
|--------|---------|-------------|
| Initial List View | Postgres | Fast pagination, short messages |
| Search (keyword) | OpenSearch | Full-text query (message, full_log) |
| View Log Details | OpenSearch → MinIO fallback | Retrieve full content |
| Analytics / Billing | Postgres | Aggregations and counts |

---

### Example Flows

#### Dashboard Load
SELECT id, service, level, message, timestamp  
FROM tenant_a.logs  
ORDER BY timestamp DESC  
LIMIT 50;

→ Displays a fast list of short messages.

#### User Searches “UUID”
Frontend → search_service  
→ Query OpenSearch  
→ Get matching log IDs  
→ Fetch metadata from Postgres  
→ Display results

#### User Clicks on One Log
Frontend → search_service  
→ Fetch from OpenSearch (fast)  
→ If missing, read from MinIO (raw JSON)

---

## Summary

| Layer | Role | Storage |
|--------|------|----------|
| Postgres | Structured metadata, UI preview, billing | SQL |
| OpenSearch | Full-text search | Indexed JSON |
| MinIO | Long-term raw backup | Object store |

---

## TL;DR Architecture in One Line

Postgres → structured view  
OpenSearch → fast search  
MinIO → reliable backup  

Together they make the Logger Hub pipeline reliable, searchable, and scalable.  

doc end  
"""
