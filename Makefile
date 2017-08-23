GIT_VERSION = $(shell git describe --always)
AWS_DEFAULT_REGION ?= eu-west-1
REPOSITORY_URL = eddylane/playlist-pal
ENV ?= testing
BACKEND_BUILD = ${CURDIR}/backend/playlist_pal.tar.gz

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

	docker build frontend \
	-f frontend/Dockerfile.release \
	-t eddylane/playlist_pal_frontend:release-0.0.1

release_backend: install_backend
	@echo "Building backend release"

	docker run --rm \
	--volume ${CURDIR}/backend:/app \
	--workdir /app \
	elixir:1.4 \
	sh -c "mix local.hex --force; mix local.rebar --force; MIX_ENV=prod mix do compile, phx.digest, release --env=prod"

	rm -f ${BACKEND_BUILD}

	cp ${CURDIR}/backend/_build/prod/rel/playlist_pal/releases/0.0.1/playlist_pal.tar.gz \
	${BACKEND_BUILD}

	docker build backend \
	-f backend/Dockerfile.release \
	-t eddylane/playlist_pal_backend:release-0.0.1