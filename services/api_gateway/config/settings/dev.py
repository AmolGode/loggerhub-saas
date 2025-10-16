from .base import *
import os

DEBUG = os.getenv("DEBUG", "True").lower() == "true"
ALLOWED_HOSTS = ["localhost", "127.0.0.1"]

#  Important for Nginx proxy (use the same port you access in browser)
CSRF_TRUSTED_ORIGINS = ["http://localhost:8100"]

# Database (using environment variables)
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.getenv("POSTGRES_DB", "loggerhub_core_db"),
        "USER": os.getenv("POSTGRES_USER", "loggerhub"),
        "PASSWORD": os.getenv("POSTGRES_PASSWORD", "postgrespassword"),
        "HOST": os.getenv("POSTGRES_HOST", "postgres"),
        "PORT": os.getenv("POSTGRES_PORT", "5432"),
    }
}
