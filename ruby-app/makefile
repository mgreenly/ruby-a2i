
.PHONY: default
default: 
	bundle config set --local path vendor/
	bundle config set --local cache_path vendor/cache
	bundle config set --local cache_all true
	bundle cache --all-platforms
	bundle lock --add-platform x86_64-linux
	bundle lock --add-platform arm64-linux
	bundle lock --add-platform darwin
	exit
	bundle show
	docker build --no-cache --secret id=token,env=TOKEN -t ruby-app:latest .

.PHONY: run
run:
	docker run -it --rm ruby-app:latest /usr/bin/bash
