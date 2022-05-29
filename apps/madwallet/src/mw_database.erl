-module(mw_database).

% API

-export([read_data/2]).
-export([write_data/3]).

% API

read_data(Table, Key) ->
    case open_table(Table) of
        {ok, Table} ->
            case dets:lookup(Table, Key) of
                [] ->
                    close_table(Table),
                    {error, {key_not_found, Key}};
                [{Key, Data}] ->
                    close_table(Table),
                    {ok, Data}
            end;
        Error ->
            {error, {open_table, Error}}
    end.

write_data(Table, Key, Data) ->
    case open_table(Table) of
        {ok, Table} ->
            dets:insert(Table, {Key, Data}),
            close_table(Table),
            ok;
        Error ->
            {error, {open_table, Error}}
    end.


% Internal

open_table(Table) ->
    Path0 = "database/" ++ binary_to_list(Table),
    Path1 = Path0 ++ "db",
    case dets:open_file(Table, [{file, Path1}]) of
        {ok, Table} ->
            {ok, Table};
        Error ->
            Error
    end.

close_table(Table) ->
    dets:close(Table).

%close_tables([]) ->
%    ok;
%close_tables([H|T]) ->
%    close_table(H),
%    close_tables(T).
%
%get_value(Table, Key) ->
%    case dets:lookup(Table, Key) of
%        [] ->
%            not_found;
%        [{Key, Value}] ->
%            {ok, Value};
%        Fail ->
%            Fail
%    end.
%
%update_value(Table, Key, Value) ->
%    dets:insert(Table, {Key, Value}).
