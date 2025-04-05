ARG EX_VSN=1.18.3
ARG OTP_VSN=27.3.2
ARG DEB_VSN=buster-20240612-slim

ARG BUILDER_IMG="hexpm/elixir:${EX_VSN}-erlang-${OTP_VSN}-debian-${DEB_VSN}"

FROM ${BUILDER_IMG} AS builder
RUN apt update && apt upgrade -y && apt install -y git

WORKDIR /app

ENV MIX_ENV=prod
RUN mix do local.hex --force, local.rebar
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be recompiled

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile
