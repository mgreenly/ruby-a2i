APPNAME=demo-app
TAGNAME=$(shell ruby -Ilib -r 'demo/app/version' -e 'puts Demo::App::VERSION')
GITHASH=$(shell git rev-parse --short HEAD)

.PHONY: default
default: 
	bundle config set --local cache_path vendor/cache
	bundle config set --local path vendor/
	bundle config set --local cache_all true
	bundle lock --add-platform x86_64-linux
	bundle lock --add-platform arm64-linux
	bundle lock --add-platform darwin
	bundle cache --all-platforms
	bundle show

.PHONY: release
release: default
	docker build \
		--secret id=token,env=TOKEN \
		--build-arg APPNAME=$(APPNAME) \
		-t "localhost/$(APPNAME):$(TAGNAME)-$(GITHASH)" \
		.

.PHONY: run
run:
	docker run -it --rm "localhost/$(APPNAME):$(TAGNAME)"
