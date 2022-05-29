-module(mw_handler).

-export([user_create/0]).
-export([user_data/0]).
-export([wallet_create/2]).
-export([wallet_delete/1]).

-export_type([user_data/0]).

-type wallets() :: mw_user:wallets().

-type user_data() :: #{
    id := binary(),
    wallets := wallets()
}.

% API

user_create() ->
    case read_data(user_data) of
        {ok, _} ->
            {error, user_already_exists};
        {error, {key_not_found, user_data}} ->
            write_data(user_data, mw_user:create(user_test())),
            {ok, user_test()}
    end.

user_data() ->
    read_data(user_data).

wallet_create(ID, Balance) ->
    mw_handler(create_wallet, {ID, Balance}).

wallet_delete(ID) ->
    mw_handler(delete_wallet, ID).

% Internal

mw_handler(Call, Args) ->
    case read_data(user_data) of
        {ok, UserData} ->
            case mw_handler(Call, Args, UserData) of
                {ok, UpdatedUserData} ->
                    write_data(user_data, UpdatedUserData),
                    ok;
                Error ->
                    Error
            end;
        {error, {key_not_found, user_data}} ->
            {error, user_data_not_found}
    end.

mw_handler(create_wallet, {ID, Balance}, UserData) ->
    mw_wallet:create(ID, Balance, UserData);
mw_handler(delete_wallet, ID, UserData) ->
    mw_wallet:delete(ID, UserData).
    

% Internal

user_test() ->
    <<"admin">>.

read_data(Key) ->
    mw_database:read_data(user_test(), Key).

write_data(Key, Data) ->
    mw_database:write_data(user_test(), Key, Data).
