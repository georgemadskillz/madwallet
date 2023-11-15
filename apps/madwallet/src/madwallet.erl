-module(madwallet).


%% API


%% Callbacks

-export([start_link/0]).

-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2
]).

%% API

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% Callbacks

init(_Args) ->
    io:format("madwallet> Started.~n", []),
    {ok, []}.

terminate(_Reason, _State) ->
    %dets:close(?TASKS_TABLE),
    ok.

handle_call(Request, From, State) ->
    io:format("Unexpected call Request=~0p From=~p~n", [Request, From]),
    {noreply, State}.

handle_cast(Request, State) ->
    io:format("Unexpected cast Request=~0p~n", [Request]),
    {noreply, State}.

handle_info(Message, State) ->
    io:format("Unexpected info Request=~0p~n", [Message]),
    {noreply, State}.

%% Internal functions

