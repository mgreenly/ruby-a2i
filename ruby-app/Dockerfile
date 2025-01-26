FROM public.ecr.aws/amazonlinux/amazonlinux:2023 AS build

COPY ./bin                /app-root/bin
COPY ./exe                /app-root/exe
COPY ./lib                /app-root/lib
COPY ./vendor/bundle      /app-root/vendor/bundle
COPY ./ruby-app.gemspec   /app-root/ruby-app.gemspec
COPY ./Gemfile            /app-root/Gemfile
COPY ./Gemfile.lock       /app-root/Gemfile.lock

RUN dnf update -y \
 && dnf group install -y 'Development Tools' \
 && dnf install -y \
    ruby \
    mariadb105-devel \
 && dnf clean -y all \
 && gem install bundler -v 2.6.2 \ 
 && chown -R 1000:1000 /app-root

USER 1000:1000

RUN cd /app-root \
 && bundle config --local deployment true \
 && bundle config --local without "development test" \
 && bundle install --local 


FROM public.ecr.aws/amazonlinux/amazonlinux:minimal AS final

RUN dnf update -y \
 && dnf install -y \
    ruby \
    mariadb105 \
 && dnf clean -y all \
 && gem install bundler -v 2.6.2

COPY --from=build /app-root/bin /opt/app-root/bin
COPY --from=build /app-root/exe /opt/app-root/exe
COPY --from=build /app-root/lib /opt/app-root/lib
COPY --from=build /app-root/ruby-app.gemspec /opt/app-root/ruby-app.gemspec
COPY --from=build /app-root/Gemfile /opt/app-root/Gemfile
COPY --from=build /app-root/Gemfile.lock /opt/app-root/.lock
COPY --from=build /app-root/vendor/bundle /opt/app-root/vendor/bundle

ENV GEM_HOME="/opt/app-root/vendor/bundle/ruby/3.2.0"
ENV GEM_PATH="opt/app-root/lib:/opt/app-root/vendor/bundle:/usr/share/ruby3.2-gems:/usr/share/gems:/usr/local/share/ruby3.2-gems:/usr/local/share/gems"

USER 1000:1000
WORKDIR /opt/app-root

