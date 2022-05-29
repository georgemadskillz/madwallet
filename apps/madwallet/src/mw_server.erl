-module(mw_server).

-behaviour(gen_server).

-define(MW_SERVER, ?MODULE).

-export([start_link/0]).
-export([ping/0]).
-export([stop/0]).

-export([init/1]).
-export([terminate/2]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_continue/2]).

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
    {ok, #{}, {continue, init}}.

terminate(_Reason, _State) ->
    %mw_database:close_tables().
    ok.

handle_continue(init, State) ->
    Dispatch = cowboy_router:compile([
        {
            '_',
            [
                {"/api/v0/user_data", mw_http_handler, []}
            ]
        }
    ]),
    {ok, _} = cowboy:start_clear(
        mw_http_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    {noreply, State}.

handle_call(ping, _From, State) ->
    {reply, pong, State}.

handle_cast(Unhandled, State) ->
    io:format("MW> mw_server -> Got unhandled Message=~p~n", [Unhandled]),
    {noreply, State}.
