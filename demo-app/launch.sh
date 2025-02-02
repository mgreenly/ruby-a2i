#!/bin/sh

#
# Ideally we'd require all *.tgz based deployables to provide a consistently
# named script that's used as the ENTRYPOINT. In this example I assume this
# file is that cript. The only requirements of this script is that it runs
# the app in the forground, waits for it to exit and ensures the main processes
# exit code is returned, beyond that there is no requirements on how it starts
# and runs the app. That makes this part of the process completely language
# agnostic.
#
# If done correctly, as shown here, you can use this script to run the app on
# your laptop as well as it being the entry point when the app is deployed in
# production.
#
# This script is utltimately created and controlled by the app evelopers. So
# this is just an example of how we'd do it for our ruby apps.
# 

# trace all commands and exit if there are any errors
set -ex

# first, provide some helpful debug info about the system
ruby -v
gem -v
bundle -v
bundle show

# then start the app
ruby \
  -I "./lib" \
  -r "bundler/setup" \
  -r "demo/app" \
  -e "Demo::App::Main.run"
