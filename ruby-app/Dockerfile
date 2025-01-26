FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS build

COPY ./bin                /opt/app-root/bin
COPY ./exe                /opt/app-root/exe
COPY ./lib                /opt/app-root/lib
COPY ./vendor/bundle      /opt/app-root/vendor/bundle
COPY ./ruby-app.gemspec   /opt/app-root/ruby-app.gemspec
COPY ./Gemfile            /opt/app-root/Gemfile
COPY ./Gemfile.lock       /opt/app-root/Gemfile.lock

RUN dnf update -y \
 && dnf group install -y 'Development Tools' \
 && dnf install -y \
      ruby \
      mariadb105-devel \
 && dnf clean -y all \
 && gem install bundler -v 2.6.2 \ 
 && chown -R 1000:1000 /opt/app-root

USER 1000:1000

WORKDIR /opt/app-root

RUN bundle config --local deployment true \
 && bundle config --local without "development test" \
 && bundle install --local \
 && mkdir out \
 && cp -R bin out/bin \
 && cp -R exe out/exe \
 && cp -R lib out/lib \
 && mkdir -p out/vendor \
 && cp -R vendor/bundle/ruby out/vendor/ruby \
 && cp ruby-app.gemspec out/ruby-app.gemspec \
 && cp Gemfile out/Gemfile \
 && cp Gemfile.lock out/Gemfile.lock \
 && tar -czf /tmp/app.tar.gz -C ./out .

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
 && tar -xzf /tmp/app.tar.gz -C /opt/app-root \
 && rm /tmp/app.tar.gz

ENV GEM_HOME="/opt/app-root/vendor/ruby/3.2.0"

USER 1000:1000
WORKDIR /opt/app-root

