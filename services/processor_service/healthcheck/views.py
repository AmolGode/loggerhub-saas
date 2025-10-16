from django.http import JsonResponse
import traceback
from rest_framework.response import Response
from rest_framework.views import APIView
from config.celery import app as celery_app

class HealthCheckView(APIView):
    def get(self, request):
        data = {
            "service": "processor_service",
            "status": "ok",
            "celery": "unavailable",
        }

        celery_error = ""
        try:
            if celery_app.control.ping(timeout=1):
                data["celery"] = "alive"
        except Exception:
            celery_error = traceback.format_exc()

        return Response({"celery_error": celery_error, "data": data})