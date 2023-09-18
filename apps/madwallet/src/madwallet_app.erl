%%%-------------------------------------------------------------------
%% @doc madwallet public API
%% @end
%%%-------------------------------------------------------------------

-module(madwallet_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    madwallet_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
