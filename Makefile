COMPOSE ?= docker compose
PROD = $(COMPOSE) -f docker-compose.yml

# Подготовка и запуск локального окружения одной командой
start: setup dev

# Подготовка: .env, сборка образов, установка зависимостей приложения
setup: prepare-env compose-build compose-install

prepare-env:
	cp -n .env.example .env || true

compose-build:
	$(COMPOSE) build

compose-install:
	$(COMPOSE) run --rm app make setup

# Разработка: app (make dev) + db + caddy, https://localhost
dev:
	$(COMPOSE) up

down:
	$(COMPOSE) down

compose-bash:
	$(COMPOSE) run --rm app bash

# Линтеры приложения внутри контейнера разработки
lint:
	$(COMPOSE) run --rm app make lint

# Продакшен-образ и тесты в нём (то же, что в CI)
compose-production-build:
	$(PROD) build

compose-test:
	$(PROD) up --abort-on-container-exit --exit-code-from app

compose-production-lint:
	$(PROD) run --rm --no-deps app make lint

lint-dockerfiles:
	docker run --rm -i hadolint/hadolint:v2.12.0 < Dockerfile
	docker run --rm -i hadolint/hadolint:v2.12.0 < Dockerfile.production

compose-clean:
	$(PROD) down -v --remove-orphans

ci: prepare-env compose-production-build compose-production-lint compose-test

# Публикация продакшен-образа (нужен docker login)
push:
	$(PROD) push app

.PHONY: start setup prepare-env compose-build compose-install dev down compose-bash lint \
	compose-production-build compose-test compose-production-lint lint-dockerfiles compose-clean ci push
