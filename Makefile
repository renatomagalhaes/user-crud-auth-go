# Docker Compose commands
.PHONY: up down logs restart build shell

# Development commands
up:
	docker-compose -f docker/dev/docker-compose.yml up -d

down:
	docker-compose -f docker/dev/docker-compose.yml down

logs:
	docker-compose -f docker/dev/docker-compose.yml logs -f app

restart:
	docker-compose -f docker/dev/docker-compose.yml restart

build:
	docker-compose -f docker/dev/docker-compose.yml build --no-cache

shell:
	docker-compose -f docker/dev/docker-compose.yml exec app sh

clean:
	docker-compose -f docker/dev/docker-compose.yml down -v --remove-orphans
