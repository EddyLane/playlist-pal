install:
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/assets \
	node:6 \
	yarn install

	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/assets \
	node:6 \
	node_modules/.bin/elm-package install -y

	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app \
	elixir:1.4 \
	sh -c "mix local.hex --force; mix local.rebar --force; mix deps.get"