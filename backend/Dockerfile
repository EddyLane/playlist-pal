FROM elixir:1.4
WORKDIR /app

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install tools for phoenix live reload
RUN apt-get update && \
    apt-get install -y inotify-tools