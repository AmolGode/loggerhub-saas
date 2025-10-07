#!/usr/bin/env bash
set -e

: "${POSTGRES_HOST:=postgres}"
: "${POSTGRES_PORT:=5432}"

echo "⏳ Waiting for PostgreSQL at ${POSTGRES_HOST}:${POSTGRES_PORT}..."
until nc -z "$POSTGRES_HOST" "$POSTGRES_PORT"; do
  echo "  waiting for postgres..."
  sleep 1
done
echo "✅ Postgres is available."

# Optional Redis wait
if [ -n "$REDIS_HOST" ]; then
  REDIS_PORT="${REDIS_PORT:-6379}"
  echo "⏳ Waiting for Redis at ${REDIS_HOST}:${REDIS_PORT}..."
  until nc -z "$REDIS_HOST" "$REDIS_PORT"; do
    echo "  waiting for redis..."
    sleep 1
  done
  echo "✅ Redis is available."
fi

# If a Django project exists (manage.py), run migrations and collectstatic
if [ -f "./manage.py" ]; then
  echo "🐍 Django project detected. Running migrations..."
  python manage.py migrate --noinput || echo "⚠️ Migrations skipped or failed"

  echo "🧹 Collecting static files..."
  python manage.py collectstatic --noinput || echo "⚠️ collectstatic skipped"

  echo "🚀 Starting application server..."
  exec "$@"
else
  echo "⚠️ No Django project (manage.py) found in /app. Skipping migrations & static setup."
  echo "🔒 Container will remain alive (tail -f /dev/null) so you can mount code later."
  exec tail -f /dev/null
fi
