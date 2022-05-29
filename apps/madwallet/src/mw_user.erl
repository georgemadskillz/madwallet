-module(mw_user).

-export([create/1]).

-export_type([wallets/0]).

-type wallets() :: #{
    binary() => mw_wallet:wallet()
}.

% API

create(ID) ->
    NewUser = #{
        user_id => ID,
        wallets => #{}
    },
    {ok, NewUser}.

% Internal
