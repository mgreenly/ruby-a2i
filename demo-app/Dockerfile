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

ARG APPNAME

# This step installs all the platorm development tools and libraries. These never
# change from one ruby app to the next.
RUN dnf update -y \
 && dnf group install -y 'Development Tools' \
 && dnf install -y findutils \
 && dnf clean -y all

#
# For stage2 we'd actually grab the image from where ever we pushed it during
# stage1, but this is just an example, so we're just using the result of the
# previous stage.
#
FROM stage1 AS stage2

# This step adds all the files we need to build the app.
COPY ./.bundle                 /opt/app-root/.bundle
COPY ./bin                     /opt/app-root/bin
COPY ./lib                     /opt/app-root/lib
COPY ./vendor                  /opt/app-root/vendor
#COPY ./*.gemspec               /opt/app-root/*.gemspec
COPY ./${APPNAME}.gemspec      /opt/app-root/${APPNAME}.gemspec
COPY ./Gemfile                 /opt/app-root/Gemfile
COPY ./Gemfile.lock            /opt/app-root/Gemfile.lock
COPY ./launch.sh               /opt/app-root/launch.sh
COPY ./.a2i/packages.prod      /opt/app-root/packages.prod
COPY ./.a2i/packages.dev       /opt/app-root/packages.dev

# This step adds all the native packages unique to this app.
RUN xargs -a /opt/app-root/packages.prod dnf install -y \
 && xargs -a /opt/app-root/packages.dev dnf install -y \
 && dnf clean -y all \
 && gem install bundler -v 2.6.2

# This step sets up a non-root environment to build the app in
RUN chown -R 1000:1000 /opt/app-root
USER 1000:1000
WORKDIR /opt/app-root

# This step uses the previously installed native dev tools and libs to build the app
RUN bundle config --local deployment true \
 && bundle config --local without "development test" \
 && bundle install --local

# This step builds the *.tgz
RUN mkdir -p out/vendor \
 && cp -R bin out/bin \
 && cp -R lib out/lib \
 && cp -R .bundle out/.bundle \
 && cp -R vendor/ruby out/vendor/ruby \
 && cp ${APPNAME}.gemspec out/${APPNAME}.gemspec \
 && cp Gemfile out/Gemfile \
 && cp Gemfile.lock out/Gemfile.lock \
 && cp launch.sh out/launch.sh \
 && tar -czf /tmp/app.tar.gz -C ./out .

# This step would ship the *.tgz to Artifactory.  I haven't finished it yet.
# so for now stage3 just copies the *.tgz from stage2.
RUN --mount=type=secret,id=token,env=TOKEN \
    echo "${TOKEN}"

#
# What follows here is just an example of extracting and using the *.tgz.  I
# will evntually move this into a seprate docker process to better mirror what 
# we'll be doing in the future.
#
# **NOTE** There doesn't have to be anything language platform specific about this
# step. If we managed a *.rpm repo mirror we could allow the devteams to include a list
# of packages in a text file that we enumerate over and install.  The packages could
# only come from that controlled mirror that contains pre-approved/scanned packages.
#
# Although personally I'd suggest we just mirror the official repo so that we could
# yank stuff if there's a CVE and AWS doesn't act quick enough.
#

FROM public.ecr.aws/amazonlinux/amazonlinux:minimal AS stage3

COPY --from=stage2 /tmp/app.tar.gz /tmp/app.tar.gz
COPY --from=stage2 /opt/app-root/packages.prod /tmp/packages.prod

WORKDIR /opt/app-root

RUN dnf update -y \
 && dnf install -y \
      tar \
      gzip \
      findutils \
 && xargs -a /tmp/packages.prod dnf install -y \
 && dnf clean -y all \
 && chown -R 1000:1000 /opt/app-root \
 && tar -xzpf /tmp/app.tar.gz -C /opt/app-root \
 && rm /tmp/app.tar.gz

USER 1000:1000
WORKDIR /opt/app-root

# the defined entrpoint for all *.tgz apps included by the dev team in the artifact.
ENTRYPOINT ["/usr/bin/sh", "-r", "-x", "/opt/app-root/launch.sh"]
