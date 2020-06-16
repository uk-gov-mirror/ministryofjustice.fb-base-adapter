DOCKER_COMPOSE = docker-compose -f docker-compose.yml

build:
	$(DOCKER_COMPOSE) build --build-arg BUNDLE_ARGS=''

test:
	$(DOCKER_COMPOSE) run -e RAILS_ENV=test --rm app bundle exec rspec
