# WARNING: You don't need to edit this file

SH := /bin/bash

APP_NAME=camunda-app
VERSION=1.0.0
LOCAL_REGISTRY=local.registry

LINTER=registry.camunda.cloud/library/cytopia/pylint@sha256:e8acf4bea77afd6a924e57fae1dfacdd5f7e288c3cc276d044a9a3a0719676f5
DOCKERFILE_LINTER=registry.camunda.cloud/library/replicated/dockerfilelint@sha256:15ce784e5847966b6d9a88cba348a9429f8b5212f6017180f10ce36b472dfe52

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build:  ## Builds docker image (for kind cluster)
	DOCKER_BUILDKIT=1 docker build -t $(LOCAL_REGISTRY)/$(APP_NAME):$(VERSION) .

# PUSH

push:  ## Pushes (loads) docker image to the Kind local cluster
	kind load docker-image $(LOCAL_REGISTRY)/$(APP_NAME):$(VERSION) --name $(CLUSTER)

# MISC

dockerfile-lint:  ## Runs Dockerfile linter
	# hadolint does not provide images suitable for M1 yet
	docker run $$( [[ "$$(uname -m)" == "arm64" ]] && echo " --platform linux/amd64" || echo "") --rm -i $(DOCKERFILE_LINTER) < Dockerfile

lint:  ## Runs linter
	docker run --rm -v `pwd`:/data \
	  $(LINTER) --rcfile=.pylintrc -s n $(shell find src -name '*.py')

fmt:  ## Runs formatter
	@echo "..."

run:
	python3 src/main.py
