#
# This step is all happening during the dev-teams CI/CD process in their
# github workflow. This is where they generate the *.tgz and ship it off
# to artifactory. We do it inside a AL2023 container so that any linking
# against native libraries is compatible with the gold image we eventually
# marry the *.tgz to.  So what follows below in the first section is ruby
# specific but the same thing could be done for every language platform.
#
FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS build

# This step adds all the files we need to build the app.
COPY ./.bundle                 /opt/app-root/.bundle
COPY ./bin                     /opt/app-root/bin
COPY ./exe                     /opt/app-root/exe
COPY ./lib                     /opt/app-root/lib
COPY ./vendor                  /opt/app-root/vendor
COPY ./ruby-app.gemspec        /opt/app-root/ruby-app.gemspec
COPY ./Gemfile                 /opt/app-root/Gemfile
COPY ./Gemfile.lock            /opt/app-root/Gemfile.lock
COPY ./launch.sh               /opt/app-root/launch.sh
COPY ./.a2i/packages.prod      /opt/app-root/packages.prod
COPY ./.a2i/packages.dev       /opt/app-root/packages.dev

# This step installs all the development tools and libraries we need to build the app.
RUN dnf update -y \
 && dnf group install -y 'Development Tools' \
 && dnf install -y findutils \
 && xargs -a /opt/app-root/packages.prod dnf install -y \
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
 && cp -R exe out/exe \
 && cp -R lib out/lib \
 && cp -R .bundle out/.bundle \
 && cp -R vendor/ruby out/vendor/ruby \
 && cp ruby-app.gemspec out/ruby-app.gemspec \
 && cp Gemfile out/Gemfile \
 && cp Gemfile.lock out/Gemfile.lock \
 && cp launch.sh out/launch.sh \
 && tar -czf /tmp/app.tar.gz -C ./out .

# This step would ship the *.tgz to Artifactory.  Faking this step for now.
RUN --mount=type=secret,id=token,env=TOKEN \
    echo "${TOKEN}"


#
# What follows here is just an example of extracting and using the *.tgz.  I
# will move this into a seprate docker process to better mirror what we'll be
# doing before before hand over the my suggested ruby pipeline.
#
# **NOTE** There doesn't have to be anything language platform specific about this
# step. If we managed a *.rpm repo mirror we could allow the devteams to include a list
# of packages in a text file that we enumerate over and install.  The packages could
# only come from that controlled mirror with pre-approved/scanned packages.  We could
# prescan these etc.  It's what I'm doing in this example with the `.a2i/packages.*`
# files.
#

FROM public.ecr.aws/amazonlinux/amazonlinux:minimal AS final

COPY --from=build /tmp/app.tar.gz /tmp/app.tar.gz
COPY --from=build /opt/app-root/packages.prod /tmp/packages.prod

WORKDIR /opt/app-root

RUN dnf update -y \
 && dnf install -y \
      tar \
      gzip \
      findutils \
 && xargs -a /tmp/packages.prod dnf install -y \
 && dnf clean -y all \
 && gem install bundler -v 2.6.2 \
 && chown -R 1000:1000 /opt/app-root \
 && tar -xzpf /tmp/app.tar.gz -C /opt/app-root \
 && rm /tmp/app.tar.gz

USER 1000:1000
WORKDIR /opt/app-root

# the defined entrpoint for all *.tgz apps included by the dev team in the artifact.
ENTRYPOINT ["/usr/bin/sh", "-r", "-x", "/opt/app-root/launch.sh"]
