GIT_VERSION = $(shell git describe --always)
AWS_DEFAULT_REGION ?= eu-west-1
ENV ?= testing

install: install_frontend install_backend
	@echo "Installed dependencies."

install_frontend:
	@echo "Installling frontend dependencies."

	docker run --rm \
	--volume ${CURDIR}/frontend:/app \
	--workdir /app \
	node:8 \
	yarn install

	docker run --rm \
	--volume ${CURDIR}/frontend:/app \
	--workdir /app \
	node:8 \
	node_modules/.bin/elm-package install -y

install_backend:
	@echo "Installling backend dependencies."

	docker run --rm \
	--volume ${CURDIR}/backend:/app \
	--workdir /app \
	elixir:1.4 \
	sh -c "mix local.hex --force; mix local.rebar --force; mix deps.get"

release: release_frontend release_backend
	@echo "Built release."

release_frontend: install_frontend
	@echo "Building frontent release"

	docker run --rm \
	--volume ${CURDIR}/frontend:/app \
	--workdir /app \
	node:8 \
	sh -c "NODE_ENV=prod node_modules/.bin/webpack"

release_backend: install_backend
	@echo "Building backend release"

	docker run --rm \
	--volume ${CURDIR}/backend:/app \
	--workdir /app \
	elixir:1.4 \
	sh -c "mix local.hex --force; mix local.rebar --force; MIX_ENV=prod mix do compile, phoenix.digest, release --env=prod"