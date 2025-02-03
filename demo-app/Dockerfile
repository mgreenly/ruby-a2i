#
# So what follows below in stage 1-2 is a ruby specific example. In this portion
# dev-teams are free to do what ever they want as long as they deliver a *.tgz
# that complies with a specification we provide.
#
# Here's a quick attempt at that spec....
#
#   * MUST use AL2023 as the base image for binary compatability.
#   * MAY specify additional package dependencies in .a2i/packages.* files
#   * Additional packages MUST be from the AWS AL2023 repository.
#   * MUST include a 'launch.sh' script at the root directory.
#   * The 'launch.sh' script MUST wait for the main process to exit.
#   * The 'launch.sh' script MUST return the exit code of the main process.
#   * All logging MUST be sent to stdout/stderr
#
# The above process supports every language platform that can run on linux without
# any additional burden to our teams.
#
# Stage 3 is our part of the work.  A bit of pipeline that can add the *.tgz file
# the dev teams create to a generic language agnostic base image.
#

FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS stage1

ARG RELEASE=false
ARG APP_NAME
ARG APP_VERSION

# This step installs all the platorm development tools and libraries. These never
# change from one ruby app to the next.
RUN dnf update -y \
 && dnf group install -y 'Development Tools' \
 && dnf install -y findutils awscli-2\
 && dnf clean -y all

# https://docs.aws.amazon.com/linux/al2023/release-notes/all-packages-AL2023.6.html

#
# For stage2 we'd actually grab the image from where ever we pushed it during
# stage1, but this is just an example, so we're just using the result of the
# previous stage.
#
FROM stage1 AS stage2

# This step adds all the files we need to build the app.
COPY ./.bundle                 /tmp/app-root/.bundle
COPY ./.a2i                    /tmp/app-root/.a2i
COPY ./bin                     /tmp/app-root/bin
COPY ./lib                     /tmp/app-root/lib
COPY ./vendor                  /tmp/app-root/vendor
COPY ./${APP_NAME}.gemspec      /tmp/app-root/${APP_NAME}.gemspec
COPY ./Gemfile                 /tmp/app-root/Gemfile
COPY ./Gemfile.lock            /tmp/app-root/Gemfile.lock
COPY ./launch.sh               /tmp/app-root/launch.sh
COPY ./launch.sh               /tmp/app-root/launch.sh1

# This step adds all the native packages unique to this app.
RUN xargs -a /tmp/app-root/.a2i/packages.prod dnf install -y \
 && xargs -a /tmp/app-root/.a2i/packages.dev dnf install -y \
 && dnf clean -y all

# This step sets up a non-root environment to build the app in
RUN chown -R 1000:1000 /tmp/app-root
USER 1000:1000
WORKDIR /tmp/app-root

ENV HOME=/tmp/app-root

# This step builds all of the apps gems
RUN bundle config --local deployment true \
 && bundle config --local without "development test" \
 && bundle install --local

# This step builds the *.tgz
USER root:root

RUN mkdir -p /tmp/${APP_NAME}_${APP_VERSION}/vendor /tmp/${APP_NAME}_${APP_VERSION}/vendor \
 && cp -R /tmp/app-root/.a2i/              /tmp/${APP_NAME}_${APP_VERSION}/.a2i \
 && cp -R /tmp/app-root/.bundle            /tmp/${APP_NAME}_${APP_VERSION}/.bundle \
 && cp -R /tmp/app-root/bin                /tmp/${APP_NAME}_${APP_VERSION}/bin \
 && cp -R /tmp/app-root/lib                /tmp/${APP_NAME}_${APP_VERSION}/lib \
 && cp -R /tmp/app-root/vendor/ruby        /tmp/${APP_NAME}_${APP_VERSION}/vendor/ruby \
 && cp /tmp/app-root/${APP_NAME}.gemspec   /tmp/${APP_NAME}_${APP_VERSION}/${APP_NAME}.gemspec \
 && cp /tmp/app-root/Gemfile               /tmp/${APP_NAME}_${APP_VERSION}/Gemfile \
 && cp /tmp/app-root/Gemfile.lock          /tmp/${APP_NAME}_${APP_VERSION}/Gemfile.lock \
 && cp /tmp/app-root/launch.sh             /tmp/${APP_NAME}_${APP_VERSION}/launch.sh

# Ship the *.tgz to S3
RUN --mount=type=secret,id=aws,required true \
 && rm -rf /tmp/${APP_NAME}_${APP_VERSION}/.bundle/cache/ \
 && rm -rf /tmp/${APP_NAME}_${APP_VERSION}/vendor/ruby/3.2.0/cache/ \
 && tar -czvf /tmp/${APP_NAME}_v${APP_VERSION}_al23_$(uname -m).tar.gz -C /tmp ${APP_NAME}_${APP_VERSION} \
 && if [ ${RELEASE} = "true" ] ; then \
      AWS_SHARED_CREDENTIALS_FILE=/run/secrets/aws \
      AWS_DEFAULT_OUTPUT=json \
      AWS_DEFAULT_REGION=us-east-1 \
      AWS_DEFAULT_PROFILE=cicd \
      aws s3 cp /tmp/${APP_NAME}_v${APP_VERSION}_al23_$(uname -m).tar.gz s3://metaspot.org/${APP_NAME}_v${APP_VERSION}_al23_$(uname -m).tar.gz ; \
     else \
      echo "RELEASE=${RELEASE}; skipping push to s3" ; \
     fi
