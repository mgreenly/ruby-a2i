APPNAME=demo-app
TAGNAME=$(shell ruby -Ilib -r 'demo/app/version' -e 'puts Demo::App::VERSION')
GITHASH=$(shell git rev-parse --short HEAD)

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

.PHONY: build
build: init cache
	docker build \
		--secret id=token,env=TOKEN \
		--build-arg APPNAME=$(APPNAME) \
		--build-arg RELEASE=false \
		-t "localhost/$(APPNAME):$(TAGNAME)-$(GITHASH)" .

.PHONY: release
release: init cache
ifneq ("", $(shell git status -z))
	bundle cache --all-platforms
	bundle show
	docker build \
		--secret id=token,env=TOKEN \
		--build-arg APPNAME=$(APPNAME) \
		--build-arg RELEASE=true \
		-t "localhost/$(APPNAME):$(TAGNAME)-$(GITHASH)" .
else
	$(error "There are uncommitted changes!")
endif

.PHONY: run
run:
	docker run -it --rm "localhost/$(APPNAME):$(TAGNAME)"
