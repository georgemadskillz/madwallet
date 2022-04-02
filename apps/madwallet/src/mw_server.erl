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
    Name = Args,
    UsersList0 = maps:get(users_list, State),
    case lists:member(Name, UsersList0) of
        false ->
            NewUser = #{
                name => Name,
                wallets => []
            },
            {ok, Name} = dets:open_file(Name, {file, "database/" ++ binary_to_list(Name)}),
            true = dets:insert_new(Name, {user, NewUser}),
            UsersList1 = [Name|UsersList0],
            ok = dets:insert(db_core, {users_list, UsersList1}),
            {reply, {ok, Name}, State#{users_list := UsersList1}};
        true ->
            {reply, {error, user_exists}, State}
    end;
handle_call(get_users, _From, State) ->
    {ok, db_core} = dets:open_file(db_core, {file, "database/db_core"}),
    [{users_list, Users}] = dets:lookup(db_core, users_list),
    {reply, {ok, Users}, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.
