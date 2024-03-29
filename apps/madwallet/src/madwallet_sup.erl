%%%-------------------------------------------------------------------
%% @doc madwallet top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(madwallet_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_one,
                 intensity => 3,
                 period => 5},
    MadwalletSpec = #{
        id => madwallet,
        start => {madwallet, start_link, []},
        restart => permanent,
        type => worker,
        modules => [madwallet]
    },
    ChildSpecs = [MadwalletSpec],
    {ok, {SupFlags, ChildSpecs}}.
