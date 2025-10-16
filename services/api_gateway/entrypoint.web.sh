#!/usr/bin/env sh
set -e

echo "🌍 Starting API Gateway ($APP_ENV)..."

if [ "$APP_ENV" = "development" ]; then
  echo "🚀 Gunicorn --reload (Dev Mode)"
  exec gunicorn config.wsgi:application \
      --bind 0.0.0.0:8000 \
      --workers 2 \
      --reload
else
  echo "🏢 Gunicorn (Prod Mode)"
  exec gunicorn config.wsgi:application \
      --bind 0.0.0.0:8000 \
      --workers 3
fi
