GIT_VERSION = $(shell git describe --always)
AWS_DEFAULT_REGION ?= eu-west-1
FRONTEND_REPOSITORY_URL = 618010546189.dkr.ecr.eu-west-1.amazonaws.com/playlist_pal_frontend
BACKEND_REPOSITORY_URL = 618010546189.dkr.ecr.eu-west-1.amazonaws.com/playlist_pal_backend
ENV ?= staging
BACKEND_BUILD = ${CURDIR}/backend/playlist_pal.tar.gz
TERRAFORM_VERSION = 0.10.2

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

ecr_login:
	$(shell	docker run --rm \
    	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
    	anigeo/awscli:latest \
    	ecr get-login --no-include-email)

release_frontend: install_frontend ecr_login
	@echo "Building frontend release"

	docker run --rm \
	--volume ${CURDIR}/frontend:/app \
	--workdir /app \
	node:8 \
	sh -c "NODE_ENV=prod node_modules/.bin/webpack"

	docker build frontend \
	-f frontend/Dockerfile.release \
	-t ${FRONTEND_REPOSITORY_URL}:${GIT_VERSION} \
	-t ${FRONTEND_REPOSITORY_URL}:latest \
	-t eddylane/playlist_pal_frontend:release-0.0.1 \
	-t eddylane/playlist_pal_frontend:latest

	docker push ${FRONTEND_REPOSITORY_URL}:${GIT_VERSION}
	docker push ${FRONTEND_REPOSITORY_URL}:latest

release_backend: install_backend ecr_login
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
	-t ${BACKEND_REPOSITORY_URL}:${GIT_VERSION} \
	-t ${BACKEND_REPOSITORY_URL}:latest \
	-t eddylane/playlist_pal_backend:release-0.0.1 \
	-t eddylane/playlist_pal_backend:latest

	docker push ${BACKEND_REPOSITORY_URL}:${GIT_VERSION}
	docker push ${BACKEND_REPOSITORY_URL}:latest

terraform_init:
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	hashicorp/terraform:${TERRAFORM_VERSION} \
	init

terraform_plan: terraform_init
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	hashicorp/terraform:${TERRAFORM_VERSION} \
	plan

terraform_apply: terraform_init
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	hashicorp/terraform:${TERRAFORM_VERSION} \
	apply

terraform_destroy: terraform_init
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	hashicorp/terraform:${TERRAFORM_VERSION} \
	destroy \
	-force