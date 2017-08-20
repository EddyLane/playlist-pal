FROM elixir:1.4

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install tools for phoenix live reload
RUN apt-get update && \
    apt-get install -y inotify-tools && \
    apt-get clean

RUN mkdir /app

WORKDIR /app
VOLUME /app