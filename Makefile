# NOServerDocker Makefile
# Facilitates building and managing Docker containers

# Variables
IMAGE_NAME = noserver
DOCKERFILE = Dockerfilev2
COMPOSE_FILE = docker-compose.yml

# Default target
.PHONY: help
help: ## Show this help message
	@echo "NOServerDocker - Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Build targets
.PHONY: build
build: ## Build the Docker image using Dockerfilev2
	docker build -f $(DOCKERFILE) -t $(IMAGE_NAME) .

.PHONY: build-no-cache
build-no-cache: ## Build the Docker image without using cache
	docker build --no-cache -f $(DOCKERFILE) -t $(IMAGE_NAME) .

.PHONY: rebuild
rebuild: clean build ## Clean and rebuild the Docker image

# Clean targets
.PHONY: clean
clean: ## Remove the Docker image
	docker rmi $(IMAGE_NAME) 2>/dev/null || true

.PHONY: clean-all
clean-all: ## Remove all Docker images and containers
	docker system prune -a -f

# Run targets
.PHONY: run
run: ## Run a single container (test mode)
	docker run --rm \
		-p 7777-7778:7777-7778/udp \
		-p 7777-7778:7777-7778/tcp \
		-v "$(PWD)/missions":/missions \
		-v "$(PWD)/replays":/replays \
		$(IMAGE_NAME) \
		--modded false \
		--name "FV | Escalation PvP" \
		--password "" \
		--port-override true \
		--port-value 7777 \
		--query-override true \
		--query-value 7778 \
		--maxplayers 32 \
		--nostoptime 1.0

.PHONY: run-interactive
run-interactive: ## Run container in interactive mode
	docker run -it --rm \
		-p 7777-7778:7777-7778/udp \
		-p 7777-7778:7777-7778/tcp \
		-v "$(PWD)/missions":/missions \
		-v "$(PWD)/replays":/replays \
		$(IMAGE_NAME) /bin/bash

# Docker Compose targets
.PHONY: up
up: ## Start all services using docker-compose
	docker-compose -f $(COMPOSE_FILE) up -d

.PHONY: down
down: ## Stop all services using docker-compose
	docker-compose -f $(COMPOSE_FILE) down

.PHONY: restart
restart: ## Restart all services
	docker-compose -f $(COMPOSE_FILE) restart

.PHONY: logs
logs: ## Show logs for all services
	docker-compose -f $(COMPOSE_FILE) logs -f

.PHONY: logs-altercation
logs-altercation: ## Show logs for altercation service
	docker-compose -f $(COMPOSE_FILE) logs -f altercation

.PHONY: logs-breakout
logs-breakout: ## Show logs for breakout service
	docker-compose -f $(COMPOSE_FILE) logs -f breakout

.PHONY: logs-confrontation
logs-confrontation: ## Show logs for confrontation service
	docker-compose -f $(COMPOSE_FILE) logs -f confrontation

.PHONY: logs-domination
logs-domination: ## Show logs for domination service
	docker-compose -f $(COMPOSE_FILE) logs -f domination

.PHONY: logs-escalation
logs-escalation: ## Show logs for escalation service
	docker-compose -f $(COMPOSE_FILE) logs -f escalation

# Status targets
.PHONY: status
status: ## Show status of all containers
	docker-compose -f $(COMPOSE_FILE) ps

.PHONY: ps
ps: ## Show running containers
	docker ps

.PHONY: images
images: ## Show Docker images
	docker images

# Development targets
.PHONY: shell
shell: ## Open shell in running container (first service)
	docker-compose -f $(COMPOSE_FILE) exec altercation /bin/bash

.PHONY: exec-altercation
exec-altercation: ## Open shell in altercation container
	docker-compose -f $(COMPOSE_FILE) exec altercation /bin/bash

.PHONY: exec-breakout
exec-breakout: ## Open shell in breakout container
	docker-compose -f $(COMPOSE_FILE) exec breakout /bin/bash

.PHONY: exec-confrontation
exec-confrontation: ## Open shell in confrontation container
	docker-compose -f $(COMPOSE_FILE) exec confrontation /bin/bash

.PHONY: exec-domination
exec-domination: ## Open shell in domination container
	docker-compose -f $(COMPOSE_FILE) exec domination /bin/bash

.PHONY: exec-escalation
exec-escalation: ## Open shell in escalation container
	docker-compose -f $(COMPOSE_FILE) exec escalation /bin/bash

# Utility targets
.PHONY: volumes
volumes: ## Create necessary volume directories
	mkdir -p missions/altercation missions/breakout missions/confrontation missions/domination missions/escalation
	mkdir -p replays logs

.PHONY: pull
pull: ## Pull latest base image
	docker pull steamcmd/steamcmd:latest

# Quick development workflow
.PHONY: dev
dev: volumes build up ## Quick development setup: create volumes, build, and start services

.PHONY: quick-test
quick-test: build run ## Quick test: build and run single container

# Maintenance
.PHONY: update
update: pull rebuild up ## Update base image, rebuild, and restart services
