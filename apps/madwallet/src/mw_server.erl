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

-export([create_user/1]).
-export([get_users/0]).
-export([create_wallet/3]).
-export([get_wallets/1]).

%% API

-spec start_link() -> {ok, _} | ignore | {error, _}.
start_link() ->
    gen_server:start_link({local, ?MW_SERVER}, ?MODULE, [], []).

ping() ->
    gen_server:call(?MW_SERVER, ping).

stop() ->
    gen_server:cast(?MW_SERVER, stop).

create_user(Name) when is_binary(Name) ->
    gen_server:call(?MW_SERVER, {create_user, Name});
create_user(_Name) ->
    {error, {name, invalid_format}}.

get_users() ->
    gen_server:call(?MW_SERVER, get_users).

create_wallet(UserName, WalletName, CurrencyName) when
    is_binary(UserName) and
    is_binary(WalletName) and
    is_binary(CurrencyName) ->
    gen_server:call(?MW_SERVER, {create_wallet, {UserName, WalletName, CurrencyName}}).

get_wallets(UserName) ->
    gen_server:call(?MW_SERVER, {get_wallets, UserName}).

%% Callbacks

init(_InitParams) ->
    case init_core() of
        {ok, UsersList} ->
            {ok, #{users_list => UsersList}};
        {error, Error} ->
            {stop, {error, Error}}
    end.

terminate(_Reason, _State) ->
    case dets:close(db_core) of
        ok ->
            ok;
        {error, Reason} ->
            io:format("WOLOLO> terminate -> Failed close db_core DETS, Reason=~p~n", [Reason]),
            error
    end.

init_core() ->
    case dets:open_file(db_core, [{file, "database/db_core"}]) of
        {ok, db_core} ->
            io:format("WOLOLO> init_core -> Opened users_list table=~n", []),
            case dets:lookup(db_core, users_list) of
                {error, Reason} ->
                    {error, Reason};
                [] ->
                    io:format("WOLOLO> init_core -> users_list not found, insert the new epmty~n", []),
                    EmptyUsersList = [],
                    case dets:insert_new(db_core, {users_list, EmptyUsersList}) of
                        {error, Reason} ->
                            {error, Reason};
                        true ->
                            {ok, []}
                    end;
                [{users_list, Users}] ->
                    io:format("WOLOLO> init_core -> Got users_list UsersList=~p~n", [Users]),
                    {ok, Users}
            end;
        {error, Error} ->
            {error, Error}
    end.

handle_call(ping, _From, State) ->
    {reply, pong, State};
handle_call({create_user, Args}, _From, State) ->
    UserName = Args,
    UsersList0 = maps:get(users_list, State),
    case lists:member(UserName, UsersList0) of
        false ->
            NewUser = #{
                name => UserName,
                wallets => #{}
            },
            {ok, UserName} = dets:open_file(UserName, {file, "database/" ++ binary_to_list(UserName)}),
            true = dets:insert_new(UserName, {user, NewUser}),
            UsersList1 = [UserName|UsersList0],
            ok = dets:insert(db_core, {users_list, UsersList1}),
            {reply, {ok, UserName}, State#{users_list := UsersList1}};
        true ->
            {reply, {error, user_exists}, State}
    end;
handle_call(get_users, _From, State) ->
    {ok, db_core} = dets:open_file(db_core, {file, "database/db_core"}),
    [{users_list, Users}] = dets:lookup(db_core, users_list),
    {reply, {ok, Users}, State};
handle_call({create_wallet, Args}, _From, State) ->
    UsersList = maps:get(users_list, State),
    {UserName, WalletName, CurrencyName} = Args,
    case lists:member(UserName, UsersList) of
        false ->
            {reply, {error, user_not_found}, State};
        true ->
            {ok, UserName} = dets:open_file(UserName, {file, "database/" ++ binary_to_list(UserName)}),
            [{user, User0}] = dets:lookup(UserName, user),
            % TODO: check if wallet exists yet
            #{wallets := Wallets} = User0,
            NewWallet = #{
                name => WalletName,
                currency => CurrencyName,
                balance => 0
            },
            User1 = User0#{wallets := Wallets#{WalletName => NewWallet}},
            ok = dets:insert(UserName, {user, User1}),
            {reply, {ok, NewWallet}, State}
    end;
handle_call({get_wallets, Args}, _From, State) ->
    UserName = Args,
    % TODO: user not found
    {ok, UserName} = dets:open_file(UserName, {file, "database/" ++ binary_to_list(UserName)}),
    [{user, User}] = dets:lookup(UserName, user),
    #{wallets := Wallets} = User,
    {reply, {ok, {wallets, Wallets}}, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.
