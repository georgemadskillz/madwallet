
-module(madwallet_server).

-behaviour(gen_server).

-define(SERVER, ?MODULE).

-export([start_link/0]).
-export([stop/0]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).


%% API


start_link() ->
    gen_server:start_link({local, madwallet_server}, madwallet_server, [], []).

stop() ->
    gen_server:cast(?SERVER, stop).

%% Callbacks

init(_InitParams) ->
    io:format("Hello, heavy world!~n"),
    {ok, #{}}.

handle_call(ping, _From, State) ->
    {reply, pong, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.


