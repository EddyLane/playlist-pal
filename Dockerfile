FROM elixir:1.4
MAINTAINER Eddy Lane <naedin@gmail.com>
WORKDIR /app

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force