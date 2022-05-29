-module(mw_wallet).

-export([create/3]).
-export([delete/2]).

-export_type([wallet/0]).

-type wallet() :: #{
    transactions := []
}.

create(ID, Balance, #{wallets := Wallets} = UserData) ->
    case maps:is_key(ID, Wallets) of
        false ->
            NewWallet = #{
                balance => Balance,
                wallet_id => ID,
                transactions => orddict:new()
            },
            {ok, UserData#{
                wallets := Wallets#{
                    ID => NewWallet}
            }};
        true ->
            {error, {wallet_already_exists, ID}}
    end.

delete(ID, #{wallets := Wallets} = UserData) ->
    case maps:is_key(ID, Wallets) of
        true ->
            {ok, UserData#{
                wallets := maps:remove(ID, Wallets)
            }};
        false ->
            {error, {wallet_not_found, ID}}
    end.
