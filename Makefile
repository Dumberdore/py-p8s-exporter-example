# WARNING: You don't need to edit this file

SH := /bin/bash

APP_NAME=ex-prometheus-app
VERSION=1.0.0
LOCAL_REGISTRY=local.registry

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

# RUN

run:
	python3 src/main.py
