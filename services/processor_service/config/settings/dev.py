# snippet for config/settings/dev.py
from .base import *
import os

ALLOWED_HOSTS = ["localhost", "127.0.0.1"]

#  Important for Nginx proxy (use the same port you access in browser)
CSRF_TRUSTED_ORIGINS = ["http://localhost:8101"]

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.environ.get("DATABASE_NAME", "loggerhub_processor_db"),
        "USER": os.environ.get("DATABASE_USER", "loggerhub"),
        "PASSWORD": os.environ.get("DATABASE_PASSWORD", "postgrespassword"),
        "HOST": os.environ.get("DATABASE_HOST", "postgres"),
        "PORT": os.environ.get("DATABASE_PORT", "5432"),
    }
}

# Celery settings (used later in phase 2)
CELERY_BROKER_URL = os.environ.get("REDIS_URL", "redis://redis:6379/1")
CELERY_RESULT_BACKEND = CELERY_BROKER_URL