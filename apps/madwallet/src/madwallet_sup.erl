-module(madwallet_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = {one_for_one, 0, 1},
    Childs = [
        {
            madwallet_server,
            {madwallet_server, start_link, []},
            permanent, 2000, worker, [madwallet_server]
        }
    ],
    {ok, {SupFlags, Childs}}.

%% internal functions
