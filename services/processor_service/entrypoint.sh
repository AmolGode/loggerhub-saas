#!/usr/bin/env bash
set -e

# allow either POSTGRES_HOST or DATABASE_HOST env var
: "${POSTGRES_HOST:=${DATABASE_HOST:-postgres}}"
: "${POSTGRES_PORT:=${DATABASE_PORT:-5432}}"

echo "⏳ Waiting for PostgreSQL at ${POSTGRES_HOST}:${POSTGRES_PORT}..."
until nc -z "$POSTGRES_HOST" "$POSTGRES_PORT"; do
  echo "  waiting for postgres..."
  sleep 1
done
echo "✅ Postgres is available."

# Optional Redis readiness (if you provide REDIS_HOST)
if [ -n "${REDIS_HOST:-}" ]; then
  REDIS_PORT="${REDIS_PORT:-6379}"
  echo "⏳ Waiting for Redis at ${REDIS_HOST}:${REDIS_PORT}..."
  until nc -z "$REDIS_HOST" "$REDIS_PORT"; do
    echo "  waiting for redis..."
    sleep 1
  done
  echo "✅ Redis is available."
fi

# If Django project present, run migrations + collectstatic
if [ -f "./manage.py" ]; then
  echo "🐍 Django project detected. Running migrations..."
  python manage.py migrate --noinput || echo "⚠️ Migrations failed or skipped"

  echo "🧹 Collecting static files..."
  python manage.py collectstatic --noinput || echo "⚠️ collectstatic skipped"
else
  echo "⚠️ No manage.py found in /app — skipping migrate/collectstatic"
fi

echo "🚀 Exec passed command"
exec "$@"