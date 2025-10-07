from rest_framework.response import Response
from rest_framework.views import APIView
from django.db import connections
from django_redis import get_redis_connection
import socket

class HealthCheckView(APIView):
    """
    Simple health endpoint to verify API Gateway and dependencies.
    """

    def get(self, request):
        checks = {}

        # DB check
        try:
            connections['default'].cursor()
            checks['postgres'] = '✅ OK'
        except Exception as e:
            checks['postgres'] = f'❌ {e}'

        # Redis check
        try:
            conn = get_redis_connection("default")
            conn.ping()
            checks['redis'] = '✅ OK'
        except Exception as e:
            checks['redis'] = f'❌ {e}'

        # MinIO check (optional — only if you want)
        try:
            socket.create_connection(("minio", 9000), timeout=2)
            checks['minio'] = '✅ OK'
        except Exception as e:
            checks['minio'] = f'❌ {e}'

        return Response({
            "status": "healthy" if all('✅' in v for v in checks.values()) else "degraded",
            "checks": checks
        })
