# pnpm нужен только для установки зависимостей. Он может не стоять глобально
# (например, в node:26-slim без corepack) — тогда та же версия, что в
# packageManager, запускается через npx.
PNPM ?= $(shell command -v pnpm >/dev/null 2>&1 && echo pnpm || echo npx --yes pnpm@12.6.0)

# Скрипты запускаются через npm run: pnpm run/exec перед запуском сверяет
# node_modules с окружением и, если зависимости ставились в другом контейнере
# или по другому пути (каталог смонтирован в /app), переустанавливает их
RUN = npm run --silent

setup: install build

install:
	$(PNPM) install

build:
	$(RUN) build

prepare-env:
	cp -n .env.example .env

start:
	NODE_ENV=production $(RUN) start

dev:
	npx concurrently "make start-frontend" "make start-backend"

start-backend:
	$(RUN) start -- --watch --verbose-watch --ignore-watch='node_modules .git dist database'

start-frontend:
	npx vite build --watch

lint:
	$(RUN) lint
	$(RUN) format:check

lint-fix:
	$(RUN) lint:fix

test:
	NODE_ENV=test $(RUN) test
