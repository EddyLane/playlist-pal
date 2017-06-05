# ./Dockerfile

# Starting from the official Elixir 1.3.4 image:
# https://hub.docker.com/_/elixir/
FROM elixir:1.3.4
MAINTAINER Eddy Lane <naedin@gmail.com>
WORKDIR /app
ENV DEBIAN_FRONTEND=noninteractive

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# Install NodeJS 7.x and the NPM
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install -y -q nodejs

# Install yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
RUN $HOME/.yarn/bin/yarn install -y

RUN apt-get install -y inotify-tools

# Install elm
RUN npm install -g elm

RUN ls -l /app