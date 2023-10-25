# Build releases with a recent Elixir, but using an older Linux
# so the executable depends on an older
# (and more widely available) GLibC version.

FROM debian:buster-slim

# Installing the dependency packages takes 90% of the time
# so we do it first to allow quick builds of images
# with varied options.

RUN \
  apt-get update && \
  apt-get install -y curl libncurses5 procps build-essential zstd unzip locales

# Set up workspace
WORKDIR /app

# Environment for Erlang
ENV ERLANG_URL=https://packages.erlang-solutions.com/erlang/debian/pool
ENV ERTS_RELEASE=24.3.3-1
ENV ERTS_PLATFORM=debian~buster_amd64
ENV PACKAGE=$ERTS_RELEASE~$ERTS_PLATFORM.deb

# Environment for Elixir
ENV ELIXIR_VERSION=1.14.2
ENV ELIXIR_ZIP=v$ELIXIR_VERSION-otp-24.zip
ENV PATH="${PATH}:/app/elixir/bin"
ENV LC_ALL=en_US.UTF-8

# Set up Erlang and Elixir
RUN \
  curl -O $ERLANG_URL/erlang-base_$PACKAGE && \
  curl -O $ERLANG_URL/erlang-ssl_$PACKAGE && \
  curl -O $ERLANG_URL/erlang-crypto_$PACKAGE && \
  curl -O $ERLANG_URL/erlang-public-key_$PACKAGE && \
  curl -O $ERLANG_URL/erlang-asn1_$PACKAGE && \
  curl -O $ERLANG_URL/erlang-syntax-tools_$PACKAGE && \
  curl -O $ERLANG_URL/erlang-inets_$PACKAGE && \
  curl -O $ERLANG_URL/erlang-mnesia_$PACKAGE && \
  curl -O $ERLANG_URL/erlang-runtime-tools_$PACKAGE && \
  dpkg -i *.deb && \
  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen && \
  mkdir elixir && \
  curl --output elixir/$ELIXIR_ZIP https://repo.hex.pm/builds/elixir/$ELIXIR_ZIP && \
  (cd elixir; unzip $ELIXIR_ZIP) && \
  mix local.hex --force && \
  mix local.rebar --force

# Copy code
COPY ../mix.* /app/
COPY ../lib /app/lib/

# Prepare build
RUN mix deps.get
