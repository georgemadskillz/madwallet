#!/bin/bash

usage() { echo "Usage: $0 {all/format/dialyze/ct/run}" 1>&2; exit 1; }

case "$1" in
  "all")
    rebar3 compile && \
    rebar3 fmt && \
    rebar3 xref && \
    rebar3 lint && \
    rebar3 dialyzer && \
    rebar3 eunit && \
    rebar3 ct
  ;;
  "format")
    rebar3 compile && \
    rebar3 fmt && \
    rebar3 xref && \
    rebar3 lint
  ;;
  "dialyze")
    rebar3 compile && \
    rebar3 dialyzer
  ;;
  "ct")
    rebar3 compile && \
    rebar3 eunit && \
    rebar3 ct
  ;;
  "run")
    rebar3 compile && \
    rebar3 shell
  ;;
  *)
    usage
  ;;
esac
