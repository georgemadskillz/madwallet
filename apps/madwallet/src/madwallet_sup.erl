-module(madwallet_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-spec start_link() -> supervisor:startlink_ret().
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

-spec init([]) -> {ok, {supervisor:sup_flags(), [supervisor:child_spec()]}}.
init([]) ->
    SupFlags = {one_for_one, 1, 1},
    Childs = [
        {
            mw_server,
            {mw_server, start_link, []},
            permanent,
            2000,
            worker,
            [mw_server]
        }
    ],
    {ok, {SupFlags, Childs}}.

%% internal functions
