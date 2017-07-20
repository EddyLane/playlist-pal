install:
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app \
	node:6 \
	yarn install

	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app \
	elixir:1.4 \
	sh -c "mix local.hex --force; mix local.rebar --force; mix deps.get"