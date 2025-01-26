
.PHONY: default
default: 
	bundle config set --local path vendor/bundle
	bundle config set --local cache_path vendor/bundle/cache
	bundle config set --local cache_all true
	bundle cache --all-platforms
	bundle update --local
	docker build -t ruby-app:latest .

.PHONY: run
run:
	docker run -it --rm ruby-app:latest /usr/bin/bash
