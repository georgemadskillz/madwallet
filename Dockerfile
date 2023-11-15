
FROM erlang:26.1.2.0-slim as builder

RUN mkdir -p /mnt/data/madwallet

COPY . \
    /madwallet/

WORKDIR /madwallet

RUN rebar3 as prod release

FROM erlang:26.1.2.0-slim

# Disable erl_crash.dump file generation
ENV ERL_CRASH_DUMP_SECONDS=0
ENV ERL_CRASH_DUMP_BYTES=0

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

COPY --from=builder /madwallet/_build/prod/rel/madwallet /madwallet

WORKDIR /madwallet

ENTRYPOINT bin/madwallet foreground
