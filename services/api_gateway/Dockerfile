# services/api_gateway/Dockerfile
FROM python:3.11-slim

ARG APP_ENV=production
ENV APP_ENV=${APP_ENV}


ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# install tools needed by entrypoint
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential netcat-openbsd \
  && rm -rf /var/lib/apt/lists/*

# copy and install dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r /app/requirements.txt

# copy service files (entrypoint / app mount will override at runtime)
COPY . /app

# ensure entrypoint is executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY entrypoint.web.sh /entrypoint.web.sh
RUN chmod +x /entrypoint.web.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
# If a Django project exists, the container will run this by default.
# If no Django project, entrypoint will keep the container alive instead.
CMD ["/entrypoint.web.sh"]