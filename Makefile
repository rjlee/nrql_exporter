.PHONY: image push
BUILD_ARGS?=--no-cache
HUB?=hub.docker.com
IMAGE?=rjlee/nrql_exporter
TAG?=latest

image:
	docker build --pull $(BUILD_ARGS) -t $(HUB)/$(IMAGE):$(TAG) .

push:
	docker push $(HUB)/$(IMAGE):$(TAG)
