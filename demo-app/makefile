APP_NAME=demo-app
APP_VERSION=$(shell ruby -Ilib -r 'demo/app/version' -e 'puts Demo::App::VERSION')
GIT_HASH=$(shell git rev-parse --short HEAD)

.PHONY: default
default:
	@echo ""
	@echo "USAGE: \"make [target]\""
	@echo ""
	@echo "targets:"
	@echo "  init      - properly initalize bundler"
	@echo "  build     - build the docker image"
	@echo "  run       - run the docker image"

.PHONY: init
init:
	git config --local merge.ff true
	git config branch.master.mergeOptions "--squash"
	bundle config set --local cache_path vendor/cache
	bundle config set --local path vendor/
	bundle config set --local cache_all true
	bundle lock --add-platform x86_64-linux
	bundle lock --add-platform arm64-linux
	bundle lock --add-platform darwin

.PHONY: cache
cache:
	bundle cache --all-platforms
	bundle show

#  DOCKER_BUILDKIT=0 \

.PHONY: build
build: init cache
	docker build \
		--file Dockerfile \
		--progress=plain \
		--secret id=aws,src=/home/mgreenly/.aws/credentials \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VERSION=$(APP_VERSION) \
		--build-arg RELEASE=false \
		-t "localhost/$(APP_NAME):$(APP_VERSION)-$(GIT_HASH)" .
	# docker buildx prune -f

.PHONY: release
release: init cache
ifneq ("", $(shell git status -z))
	bundle cache --all-platforms
	bundle show
	docker build \
		--file Dockerfile \
		--progress=plain \
		--secret id=aws,src=/home/mgreenly/.aws/credentials \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VERSION=$(APP_VERSION) \
		--build-arg RELEASE=true \
		-t "localhost/$(APP_NAME):$(APP_VERSION)-$(GIT_HASH)" .
else
	$(error "There are uncommitted changes!")
endif

.PHONY: validate
validate: init cache
	docker build \
		--file Dockerfile.a2i \
		--no-cache \
		--progress=plain \
		--secret id=aws,src=/home/mgreenly/.aws/credentials \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VERSION=$(APP_VERSION) \
		--build-arg RELEASE=false \
		-t "localhost/a2i:latest" .
	docker run -it --rm \
		--user=root \
		--workdir=/opt/app-root \
    --entrypoint=/usr/bin/sh \
		localhost/a2i:latest -r -x /opt/app-root/launch.sh




.PHONY: run
run:
	docker run -it --rm "localhost/$(APP_NAME):$(APP_VERSION)-$(GIT_HASH)"
