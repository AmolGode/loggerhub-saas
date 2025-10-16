# services/processor_service/config/celery.py
import os
from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.dev")
app = Celery("processor_service")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()