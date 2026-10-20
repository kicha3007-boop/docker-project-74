# Упаковка в Docker Compose

[![hexlet-check](https://github.com/kicha3007-boop/docker-project-74/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/kicha3007-boop/docker-project-74/actions/workflows/hexlet-check.yml)
[![push](https://github.com/kicha3007-boop/docker-project-74/actions/workflows/push.yml/badge.svg)](https://github.com/kicha3007-boop/docker-project-74/actions/workflows/push.yml)

Автоматизация развертывания и обновления локального окружения с помощью Docker Compose, Github Actions (CI), Makefile.

Учебный проект Хекслета: https://ru.hexlet.io/programs/docker
Как это должно работать: https://asciinema.org/a/zVrFYtslVReMsTyqEEetdWUY5

В Docker упаковано приложение [JS Fastify Blog](https://github.com/hexlet-components/js-fastify-blog)
(каталог `app/`): Fastify + PostgreSQL, ассеты собираются Vite.

## Образ на Docker Hub

`kicha3007boop/docker-project-74` — https://hub.docker.com/r/kicha3007boop/docker-project-74

CI публикует его после успешных тестов на push в `main` с тегами `latest` и SHA коммита.
Публикация включается секретами репозитория `DOCKERHUB_USERNAME` и `DOCKERHUB_TOKEN`
(имя образа можно сменить переменной репозитория `DOCKERHUB_IMAGE`); без секретов CI только проверяет.

```bash
docker run -p 8080:8080 kicha3007boop/docker-project-74
# с внешней базой
docker run -p 8080:8080 \
  -e DATABASE_HOST=<host> -e DATABASE_NAME=postgres \
  -e DATABASE_USERNAME=postgres -e DATABASE_PASSWORD=<password> \
  kicha3007boop/docker-project-74
```

Без `DATABASE_HOST` приложение поднимает PostgreSQL внутри процесса (PGlite).

## Требования

- Docker 24+ с плагином Docker Compose v2 (`docker compose version`)
- GNU Make
- Свободные порты 80, 443 и 8080

Node.js и PostgreSQL на хосте не нужны — всё работает в контейнерах.

## Устройство

| Файл | Назначение |
|---|---|
| `Dockerfile` | образ для разработки: Node 26 и pnpm, код монтируется томом |
| `Dockerfile.production` | продакшен-образ: зависимости и код внутри, сборка ассетов, пользователь `node` |
| `docker-compose.yml` | продакшен-образ приложения + PostgreSQL; запускает тесты, порты не открыты |
| `docker-compose.override.yml` | разработка: образ из `Dockerfile`, `make dev`, порт 8080 и Caddy (80/443) |
| `services/caddy/Caddyfile` | обратный прокси с HTTPS (самоподписной сертификат) и сжатием |
| `.env.example` | переменные подключения к базе, копируется в `.env` |

Данные PostgreSQL лежат в томе `pgdata` и переживают пересоздание контейнеров.
Приложение стартует только после того, как база прошла healthcheck (`pg_isready`).

## Установка и запуск

```bash
git clone https://github.com/kicha3007-boop/docker-project-74.git
cd docker-project-74
make start   # make setup + make dev
```

Откройте https://localhost (http://localhost перенаправляет на https) или http://localhost:8080.

## Команды

```bash
make setup                # .env из .env.example, сборка образов, установка зависимостей приложения
make dev                  # запуск окружения разработки (app + db + caddy)
make down                 # остановка
make lint                 # линтеры приложения (oxlint, oxfmt) в контейнере
make lint-dockerfiles     # hadolint для Dockerfile и Dockerfile.production
make compose-test         # тесты в продакшен-образе: docker compose -f docker-compose.yml up ...
make ci                   # то же, что в CI: сборка продакшен-образа, линтер и тесты
make compose-bash         # shell в контейнере приложения
make push                 # публикация продакшен-образа (после docker login)
```

Тесты вручную:

```bash
docker compose -f docker-compose.yml up --abort-on-container-exit --exit-code-from app
```

---

<details>
<summary>Автоматические тесты Хекслета</summary>

Тесты запускаются на каждый коммит. За запуск отвечает файл `.github/workflows/hexlet-check.yml` — не удаляйте и не переименовывайте ни его, ни репозиторий.

</details>

## О Хекслете

[Хекслет](https://ru.hexlet.io/) — школа программирования: авторские программы обучения с практикой, поддержкой наставников и реальными проектами, которые остаются в резюме. Этот репозиторий — один из таких проектов.
