# To use or update to a ruby version, change {BASE_RUBY_IMAGE}
ARG BASE_RUBY_IMAGE=ruby:3.1.2-alpine3.16

FROM ${BASE_RUBY_IMAGE} AS gems

RUN apk -U upgrade && \
    apk add --update --no-cache make postgresql-dev build-base tzdata

RUN echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

ENV LANG=en_GB.UTF-8 \
    APP_ENV=production

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem update --system && \
    bundler -v && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle --retry=5 --jobs=4 --without=development && \
    rm -rf /usr/local/bundle/cache

COPY . .

FROM ${BASE_RUBY_IMAGE} AS production

RUN apk -U upgrade && \
    apk add --update --no-cache make postgresql-dev postgresql-client

WORKDIR /app

RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

COPY --from=gems /app /app
COPY --from=gems /usr/local/bundle/ /usr/local/bundle/

ARG SHA
ENV SHA=${SHA}

CMD bundle exec rackup -p3000 --host 0.0.0.0

