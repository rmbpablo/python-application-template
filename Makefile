# ======================
# ==== CONFIG ==========
# ======================

# Container/service name used by docker-compose
SERVICE_NAME = python_application_template

# Python virtual environment path for local development
VENV = venv
PYTHON = $(VENV)/bin/python

# Default docker-compose files
COMPOSE_FILES = -f docker-compose.yaml

# ======================
# === PROD COMMANDS ====
# ======================

# Build production image
build:
	docker compose $(COMPOSE_FILES) build

# Rebuild production image
rebuild:
	docker compose $(COMPOSE_FILES) build --no-cache

# Start production container (detached)
up:
	docker compose $(COMPOSE_FILES) up -d

# Stop and remove production containers, networks
down:
	docker compose $(COMPOSE_FILES) down

# Show container logs (follow mode)
logs:
	docker compose logs -f $(SERVICE_NAME)

# Open terminal shell inside the container
terminal:
	docker compose $(COMPOSE_FILES) run -it --rm --entrypoint /bin/bash $(SERVICE_NAME)

# ======================
# === DEV COMMANDS  ====
# ======================

# Build development image
build-dev:
	DOCKER_BUILD_TARGET=dev docker compose $(COMPOSE_FILES) build

# Rebuild development image
rebuild-dev:
	DOCKER_BUILD_TARGET=dev docker compose $(COMPOSE_FILES) build --no-cache

# Start development container
up-dev:
	DOCKER_BUILD_TARGET=dev docker compose $(COMPOSE_FILES) up -d

# Enter development container shell
shell-dev: up-dev
	docker exec -it $(SERVICE_NAME) bash

# Open terminal shell inside the development container
terminal-dev: build-dev
	DOCKER_BUILD_TARGET=dev docker compose $(COMPOSE_FILES) run -it --rm --entrypoint /bin/bash $(SERVICE_NAME)

# Stop development container
down-dev:
	docker compose $(COMPOSE_FILES) down

# ======================
# === TEST & LINT (DOCKER) ===
# ======================

# Run tests inside dev container
test-dev: build-dev
	#docker exec -it $(SERVICE_NAME) pytest -vv
	docker-compose $(COMPOSE_FILES) run --rm --entrypoint "bash -c 'python3 -m pytest --junitxml=logs/test-results.xml tests'" $(SERVICE_NAME)

# # Run tests inside production container
# test-prod: build
# 	docker-compose $(COMPOSE_FILES) run --rm --entrypoint "bash -c 'python3 -m pytest --junitxml=logs/test-results.xml tests'" $(SERVICE_NAME)

# Run linters inside dev container (adjust tools as needed)
lint: build-dev
	docker-compose $(COMPOSE_FILES) run --rm --entrypoint "bash -c 'pre-commit run --all-files'" $(SERVICE_NAME)

pre-commit:
	docker compose $(COMPOSE_FILES) run --rm --entrypoint "bash" $(SERVICE_NAME) -c "git init && pre-commit run --all-files"

# ======================
# === LOCAL ENV SETUP ===
# ======================

# Create local virtual environment and install dev dependencies
local-venv:
	uv venv $(VENV)
	source venv/bin/activate \
	&& uv pip install -r requirements/requirements.txt \
	&& uv pip install -r requirements/requirements-dev.txt

# Remove local virtual environment
local-clean:
	rm -rf $(VENV)

# ======================
# === TEST & LINT (LOCAL) ===
# ======================

# Run tests locally
local-test:
	$(VENV)/bin/pytest -vv

# Run linters locally
local-pre-commit:
	$(VENV)/bin/pre-commit run --all-files


# ======================
# === UTILITIES ========
# ======================

# Clean unused Docker images, networks and volumes
clean:
	docker system prune -f
	docker volume prune -f
