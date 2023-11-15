ifneq ($(shell docker compose version 2>/dev/null),)
  DOCKER_COMPOSE=docker compose
else
  DOCKER_COMPOSE=docker-compose
endif

build:
	$(DOCKER_COMPOSE) build

up:
	$(DOCKER_COMPOSE) build && $(DOCKER_COMPOSE) up && $(DOCKER_COMPOSE) logs --tail 100 -f

run:
	$(DOCKER_COMPOSE) build && $(DOCKER_COMPOSE) up -d && $(DOCKER_COMPOSE) logs --tail 100 -f

