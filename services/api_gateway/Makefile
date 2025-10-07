# ===============
#  Django Service Makefile (Reusable)
#  Works inside Docker container context.

#  Usage:
#     make install pkg=<package>
#     make freeze
#     make rebuild
#     make migrate

# ===============

COMPOSE_FILE := ../../infra/docker-compose.yml
svc ?= api_gateway

# Install a package and sync requirements
install:
	@echo "📦 Installing $(pkg) into $(svc)..."
	docker compose -f $(COMPOSE_FILE) exec $(svc) pip install $(pkg)
	docker compose -f $(COMPOSE_FILE) exec $(svc) sh -c "pip freeze > requirements.txt"
	@echo "✅ Installed and synced requirements.txt for $(svc)"

# Freeze dependencies to requirements.txt
freeze:
	@echo "❄️ Freezing dependencies for $(svc)..."
	docker compose -f $(COMPOSE_FILE) exec $(svc) sh -c "pip freeze > requirements.txt"
	@echo "✅ requirements.txt updated for $(svc)"

# Run migrations
migrate:
	@echo "🧩 Running migrations for $(svc)..."
	docker compose -f $(COMPOSE_FILE) exec $(svc) python manage.py migrate
	@echo "✅ Migrations complete."

# Open Django shell
shell:
	@echo "🐚 Opening Django shell for $(svc)..."
	docker compose -f $(COMPOSE_FILE) exec $(svc) python manage.py shell

# Collect static files
collectstatic:
	@echo "🧹 Collecting static files for $(svc)..."
	docker compose -f $(COMPOSE_FILE) exec $(svc) python manage.py collectstatic --noinput
	@echo "✅ Static files collected."

# Restart only this service
restart:
	docker compose -f $(COMPOSE_FILE) restart $(svc)
	@echo "🔄 Restarted $(svc)."
