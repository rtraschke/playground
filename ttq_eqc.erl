-module(ttq_eqc).

-compile([export_all]).

-include_lib("proper.hrl").

prop_add_offset() ->
	?FORALL({TS, OFF}, {{integer(0, 999999), integer(0, 999999), integer(0, 999999)},integer(0, 999999)},
	begin
		{Mega1, Secs1, Micro1} = TS,
		{Mega2, Secs2, Micro2} = ttq:add_offset(TS, OFF),
		(((Mega1*1000000)+Secs1)*1000000)+Micro1+(OFF*1000)
			=:= (((Mega2*1000000)+Secs2)*1000000)+Micro2
	end).

prop_is_earlier_or_equal() ->
	?FORALL({T1, T2}, {{integer(0, 999999), integer(0, 999999), integer(0, 999999)},
			{integer(0, 999999), integer(0, 999999), integer(0, 999999)}},
	begin
		{Mega1, Secs1, Micro1} = T1,
		{Mega2, Secs2, Micro2} = T2,
		( (((Mega1*1000000)+Secs1)*1000000)+Micro1 =< (((Mega2*1000000)+Secs2)*1000000)+Micro2 )
			=:= ttq:is_earlier_or_equal(T1, T2)
	end).


-ifdef(false).

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
