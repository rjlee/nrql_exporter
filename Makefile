ifneq (,)
.error This Makefile requires GNU Make.
endif


# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------
.PHONY: help lint
SHELL := /bin/bash
IMAGE = flaconi/nrql_exporter
TAG = latest


FL_VERSION = 0.4
FL_IGNORES = .git/,.github/)


# -------------------------------------------------------------------------------------------------
# Default Target
# -------------------------------------------------------------------------------------------------
help:
	@echo "lint              Lint repository files"

# -------------------------------------------------------------------------------------------------
# Lint Targets
# -------------------------------------------------------------------------------------------------
lint: _lint-files

.PHONY: _lint-files
_lint-files:
	@echo "# --------------------------------------------------------------------"
	@echo "# Lint files"
	@echo "# -------------------------------------------------------------------- #"
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-cr --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-crlf --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-trailing-single-newline --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-trailing-space --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-utf8 --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) file-utf8-bom --text --ignore '$(FL_IGNORES)' --path .
	@docker run --rm $$(tty -s && echo "-it" || echo) -v $(PWD):/data cytopia/file-lint:$(FL_VERSION) git-conflicts --text --ignore '$(FL_IGNORES)' --path .

# -------------------------------------------------------------------------------------------------
# Docker Targets
# -------------------------------------------------------------------------------------------------
docker-login:
	@yes | docker login --username $(DOCKERHUB_USERNAME) --password $(DOCKERHUB_PASSWORD)

docker-build:
	docker build $(NO_CACHE) \
		--label "org.opencontainers.image.created"="$$(date --rfc-3339=s)" \
		--label "org.opencontainers.image.revision"="$$(git rev-parse HEAD)" \
		--label "org.opencontainers.image.version"="${VERSION}" \
		-t $(IMAGE):$(TAG) .

docker-push:
	docker push $(IMAGE):$(TAG)

docker-pull-base-image:
	@grep -E '^\s*FROM' Dockerfile \
		| sed -e 's/^FROM//g' -e 's/[[:space:]]*as[[:space:]]*.*$$//g' \
		| xargs -n1 docker pull;
