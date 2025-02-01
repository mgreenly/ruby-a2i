#!/bin/sh

# Ideally we'd require all *.tgz based deployables to provide a consistently
# named script that's used as the ENTRYPOINT. In this example I assume this
# file is that cript. The only requirements of this script is that it runs
# the app in the forground, waits for it to exit and ensures the main processes
# exit code is returned, beyond that there is no requirements on how it starts
# and runs the app. This makes this part of the process completely language
# agnostic.

# exit if there's an error and show the commands as they run
set -ex

# provide some helpful debug info about the system
ruby -v
gem -v
bundle -v
bundle show

# start the app
ruby \
  -I "./lib" \
  -r "bundler/setup" \
  -r "ruby/app" \
  -e "Ruby::App::Main.run"
