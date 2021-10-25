-module(madwallet_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", cowboy_static, {priv_file, madwallet, "index.html"}},
            {"/websocket", mw_websocket, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(chat_http_listener,
        [{port, 8001}],
        #{env => #{dispatch => Dispatch}}
    ),

    madwallet_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
