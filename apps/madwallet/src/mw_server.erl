-module(mw_server).

-behaviour(gen_server).

-define(MW_SERVER, ?MODULE).

-export([start_link/0]).
-export([ping/0]).
-export([stop/0]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).

%% API

-spec start_link() -> {ok, _} | ignore | {error, _}.
start_link() ->
    gen_server:start_link({local, ?MW_SERVER}, ?MODULE, [], []).

ping() ->
    gen_server:call(?MW_SERVER, ping).

stop() ->
    gen_server:cast(?MW_SERVER, stop).

%% Callbacks

init(_InitParams) ->
    io:format("Hello, heavy world!~n"),
    {ok, #{}}.

handle_call(ping, _From, State) ->
    {reply, pong, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.
