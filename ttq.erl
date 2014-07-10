-module(ttq).

-export([add_offset/2, is_earlier_or_equal/2]).

-include("ttq.hrl").

-spec ttq:add_offset(timestamp(), offset_ms()) -> timestamp().
add_offset({MegaSecs, Secs, MicroSecs}, MilliSecs) when MilliSecs >= 0 ->
	TotMicroSecs = MicroSecs + 1000*MilliSecs,
	NewMicroSecs = TotMicroSecs rem 1000000,
	TotSecs = Secs + (TotMicroSecs div 1000000),
	NewSecs = TotSecs rem 1000000,
	NewMegaSecs = MegaSecs + (TotSecs div 1000000),
	{NewMegaSecs, NewSecs, NewMicroSecs}.

-spec ttq:is_earlier_or_equal(timestamp(), timestamp()) -> boolean().
is_earlier_or_equal(T1, T2) ->
	timer:now_diff(T2, T1) >= 0.

