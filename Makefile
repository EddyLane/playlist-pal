GIT_VERSION = $(shell git describe --always)
AWS_DEFAULT_REGION ?= eu-west-1
ENV ?= testing

install:
	docker run --rm \
	--volume ${CURDIR}/frontend:/app \
	--workdir /app \
	node:6 \
	yarn install

	docker run --rm \
	--volume ${CURDIR}/frontend:/app \
	--workdir /app \
	node:6 \
	node_modules/.bin/elm-package install -y

	docker run --rm \
	--volume ${CURDIR}/backend:/app \
	--workdir /app \
	elixir:1.4 \
	sh -c "mix local.hex --force; mix local.rebar --force; mix deps.get"