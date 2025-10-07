from .base import *
import os

DEBUG = os.getenv("DEBUG", "True").lower() == "true"
ALLOWED_HOSTS = os.getenv("ALLOWED_HOSTS", "*").split(",")

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
