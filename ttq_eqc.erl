-module(ttq_eqc).

-compile([export_all]).

-include("ttq.hrl").

-include_lib("proper.hrl").

% The properties for the timestamp operations:

ts_to_micro({Mega, Secs, Micro}) ->
	(((Mega * 1000000) + Secs) * 1000000) + Micro.

prop_add_offset() ->
	?FORALL({TS, OFF}, {timestamp(), offset_ms()},
	begin
		( ts_to_micro(TS) + (OFF * 1000) ) =:= ts_to_micro(ttq:add_offset(TS, OFF))
	end).

prop_is_earlier_or_equal() ->
	?FORALL({T1, T2}, {timestamp(), timestamp()},
	begin
		( ts_to_micro(T1) =< ts_to_micro(T2) ) =:= ttq:is_earlier_or_equal(T1, T2)
	end).


-ifdef(false).

% The properties modelling the queue:

-record(state, {ttq, model}).

prop_test() ->
	?FORALL(Cmds, commands(ttq), begin
		{H, S, Res} = run_commands(ttq, Cmds),
		cleanup(S#state.ttq),
		Res == ok
	end).

command(S) ->
	oneof([
		{call, ttq, start_link, []},
		{call, ttq, put, [S#state.ttq, messages()]},
		{call, ttq, get, [S#state.ttq]}
	]).

messages() ->
	list(message()).

message() ->
	oneof([
		{timestamp, integer(), erlang:now()},
		{offset, integer(), integer(0, inf)}
	]).

initial_state() ->
	#state{}.

next_state(S, V, {call, ttq, start_link, []}) ->
next_state(S, V, {call, ttq, put, [Ref, [{timestamp, Msg, TS}]]}) ->
next_state(S, V, {call, ttq, put, [Ref, [{offset, Msg, Offset}]]}) ->
next_state(S, V, {call, ttq, get, [Ref]}) ->

precondition(S, {call, _, start_link, []}) ->
	S#state.ttq == undefined;
precondition(S, {call, _, put, [Ref, _]}) ->
	Ref /= undefined;
precondition(S, {call, _, get, [Ref]}) ->
	Ref /= undefined.

postcondition(S, {call, ttq, get, [Ref]}, R) ->
postcondition(S, _, _) ->
	true.


cleanup(undefined) ->
	ok;
cleanup(Pid) ->
	exit(Pid, kill).

-endif.
