#
# This step is all happening during the devteams CI/CD process in their
# github workflow. This is where they generate the *.tgz and ship it off
# to artifactory. We do it inside a AL2023 container so that any linking
# against native libraries is compatible with the gold image we eventually
# marry the *.tgz to.  So what follows below is ruby specific, but the
# same thing could be done for every language platform.
#
FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS build

# add all the files we need to build the app and its gems
COPY ./.bundle            /opt/app-root/.bundle
COPY ./bin                /opt/app-root/bin
COPY ./exe                /opt/app-root/exe
COPY ./lib                /opt/app-root/lib
COPY ./vendor             /opt/app-root/vendor
COPY ./ruby-app.gemspec   /opt/app-root/ruby-app.gemspec
COPY ./Gemfile            /opt/app-root/Gemfile
COPY ./Gemfile.lock       /opt/app-root/Gemfile.lock
COPY ./launch.sh          /opt/app-root/launch.sh

# Install all development libraries and tools, needed to compile native gems.
RUN dnf update -y \
 && dnf group install -y 'Development Tools' \
 && dnf install -y \
      ruby \
      mariadb105-devel \
 && dnf clean -y all \
 && gem install bundler -v 2.6.2 

# The build step should not be done as root so we create a user
# environment to do the build in.
RUN chown -R 1000:1000 /opt/app-root
USER 1000:1000
WORKDIR /opt/app-root

# This step uses the previously installed native dev tools. It first 
# configures bundler than runs bundle install which will build build
# any gems that use native system libraries.
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

# The final step ships the *.tgz to external storage
RUN --mount=type=secret,id=token,env=TOKEN \
    echo "${TOKEN}"

#
# There doesn't have to be anything language platform specific about the images
# that run *.tgz based artifacts except the list of packages they install. If
# we could figure out how to let the user specificy a list of packages they need
# but require they come front a controlled repo for example we could support
# every language platform supported by Amazon Linux with no additional effort.
#
# The artifact could simply have a `packages` file that we try to install but
# that process only succeeds if the packages exist in our controlled mirror.
#
FROM public.ecr.aws/amazonlinux/amazonlinux:minimal AS final

COPY --from=build /tmp/app.tar.gz /tmp/app.tar.gz

WORKDIR /opt/app-root

RUN dnf update -y \
 && dnf install -y \
      tar \
      gzip \
      ruby \
      mariadb105 \
 && dnf clean -y all \
 && gem install bundler -v 2.6.2 \
 && chown -R 1000:1000 /opt/app-root \
 && tar -xzpf /tmp/app.tar.gz -C /opt/app-root \
 && rm /tmp/app.tar.gz

USER 1000:1000
WORKDIR /opt/app-root

# the defined entrpoint for all *.tgz apps included by the dev team in teh artifact.
ENTRYPOINT ["/usr/bin/sh", "-r", "-x", "/opt/app-root/launch.sh"]
