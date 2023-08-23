# To use or update to a ruby version, change {BASE_RUBY_IMAGE}
ARG BASE_RUBY_IMAGE=ruby:3.1.2-slim

FROM ${BASE_RUBY_IMAGE} AS gems

# Update and install build dependencies
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y build-essential libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock .

ENV BUNDLER_WITHOUT="development test"

RUN gem update --system && \
    bundler -v && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle --retry=5 --jobs=4 && \
    rm -rf /usr/local/bundle/cache

FROM ${BASE_RUBY_IMAGE} AS production

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y tzdata sqlite3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo export PATH=/usr/local/bin:\$PATH >> /root/.bashrc
ENV ENV="/root/.bashrc"

RUN echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

ENV LANG=en_GB.UTF-8 \
    APP_ENV=production

WORKDIR /app

# Bail if this file isn't present
COPY db/gias.sqlite3 db/gias.sqlite3
COPY --from=gems /usr/local/bundle/ /usr/local/bundle/
COPY . .

ARG SHA
ENV SHA=${SHA}
ENV RACK_ENV=production

CMD bundle exec rackup -p3000 --host 0.0.0.0
