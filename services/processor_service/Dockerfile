FROM python:3.11-slim

WORKDIR /app

# Install tools (for waiting on Postgres/Redis)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential netcat-openbsd \
  && rm -rf /var/lib/apt/lists/*

# Copy dependencies and install
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy app source code
COPY . /app

# Copy entrypoint separately to root and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8001", "--workers", "3", "--reload"]