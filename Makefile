.PHONY: help install test build run clean docker-build docker-run docker-stop pre-commit secrets-baseline

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

install: ## Install pre-commit hooks
	pip install pre-commit detect-secrets
	pre-commit install
	@echo "✅ Pre-commit hooks installed"

secrets-baseline: ## Generate/update secrets baseline
	detect-secrets scan --baseline .secrets.baseline
	@echo "✅ Secrets baseline updated"

test: ## Run pre-commit hooks
	pre-commit run --all-files
	@echo "✅ Pre-commit checks passed"

build: ## Build Docker image
	docker build -t astra-geo-mapper:latest .
	@echo "✅ Docker image built"

run: ## Run Docker container
	docker run -d --name astra-geo-mapper -p 8080:80 astra-geo-mapper:latest
	@echo "✅ Container running on http://localhost:8080"

docker-build: build ## Alias for build

docker-run: run ## Alias for run

docker-stop: ## Stop Docker container
	docker stop astra-geo-mapper || true
	docker rm astra-geo-mapper || true
	@echo "✅ Container stopped"

clean: docker-stop ## Clean up Docker resources
	docker rmi astra-geo-mapper:latest || true
	@echo "✅ Cleanup complete"

docker-compose-up: ## Start with docker-compose
	docker-compose up -d
	@echo "✅ Started with docker-compose on http://localhost:8080"

docker-compose-down: ## Stop docker-compose
	docker-compose down
	@echo "✅ Stopped docker-compose"

security-scan: ## Run security scan
	detect-secrets scan --baseline .secrets.baseline
	@echo "✅ Security scan complete"
