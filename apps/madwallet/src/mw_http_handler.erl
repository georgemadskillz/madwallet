-module(mw_http_handler).

-export([init/2]).
-export([content_types_provided/2]).
-export([request_callback/2]).

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
    {[
      {<<"application/json">>, request_callback}
     ], Req, State}.

    %io:format("WOLOLO> http -> Got Qs=~p~n", [cowboy_req:qs(Req)]),
    %PathInfo = cowboy_req:path_info(Req),
    %io:format("WOLOLO> http -> PathInfo=~p~n", [PathInfo]),
    %BindName = cowboy_req:binding(name, Req),
    %io:format("WOLOLO> http -> BindName=~p~n", [BindName]),
    %cowboy_req:reply(404, #{<<"content-type">> => <<"text-plain">>}, <<"WOLOLO">>, Req),

request_callback(Req0, State) ->
    io:format("WOLOLO> http -> Got Req=~p~n", [Req0]),
    {ok, Req1, Body} = read_body(Req0),
    Data = decode_body(Body),
    case check_api_path(cowboy_req:path(Req1)) of
        {ok, Handler} ->
            Response = mw:Handler(Data),
            EncodedResponse = encode_response(Response),
            {EncodedResponse, Req1, State};
        unknown ->
            {<<"Error: unknown API path">>, Req1, State}
    end.

check_api_path(<<"/api/v0/user_data">>) ->
    {ok, user_data};
check_api_path(UnknownPath) ->
    io:format("MW> Unknown API Path=~p~n", [UnknownPath]),
    unknown.

read_body(Req) ->
    read_body(Req, <<"">>).

read_body(Req0, Acc) ->
    case cowboy_req:read_body(Req0) of
        {ok, Req1, Data} ->
            {ok, Req1, <<Acc/binary, Data/binary>>};
        {more, Req1, Data} ->
            read_body(Req1, <<Acc/binary, Data/binary>>)
    end.

decode_body(_Body) ->
    #{<<"user">> => <<"george">>}.

encode_response(_Response) ->
    Body = io_lib:format("{
        \"not_found\": \"wololo-mololo\",
        \"some_number\": \"~p\"
    }", [42]),
    list_to_binary(Body).
