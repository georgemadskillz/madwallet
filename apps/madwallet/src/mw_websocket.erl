-module(mw_websocket).

-export([init/2]).
-export([websocket_handle/2]).
-export([websocket_info/2]).
-export([terminate/3]).

%-type connection_state() :: #{
%    authorized := false | true
%}.

-define(DISCONNECT_TIMEOUT, 60000).

init(Req, _State) ->
    io:format("Init websocket [pid=~p]..~n", [self()]),
    {cowboy_websocket, Req, #{authorized => false}, #{idle_timeout => ?DISCONNECT_TIMEOUT}}.

websocket_handle({text, <<"password&", Password/binary>>}, #{authorized := false} = State) ->
    io:format("Websocket [pid=~p]: got connection request with password=~p~n", [self(), Password]),
    case check_password(Password) of
        ok ->
            {[{active, true}, {text, <<"password&authorized">>}], State#{authorized => true}};
        failed ->
            {[{active, true}, {text, <<"password&wrong">>}], State}
    end;
websocket_handle({text, <<"msg&ping">>}, #{authorized := true} = State) ->
    websocket_frame(<<"msg&pong">>, State);
websocket_handle({text, Echo}, #{authorized := true} = State) ->
    websocket_frame(Echo, State);
websocket_handle(Frame, State) ->
    io:format("Websocket [pid=~p] invalid frame=~p..~n", [self(), Frame]),
    websocket_frame(State).

websocket_info(Msg, State) ->
    io:format("Websocket [pid=~p]: unknown erlang request=~p..~n", [self(), Msg]),
    {ok, State}.

terminate(Reason, _Req, _Nick) ->
    io:format("Websocket: terminate with reason=~p~n", [Reason]),
    ok.

websocket_frame(State) ->
    {[{active, true}], State}.

websocket_frame(Message, State) ->
    {[{active, true}, {text, Message}], State}.

check_password(<<"wololoPassword">>) ->
    ok;
check_password(_) ->
    failed.
