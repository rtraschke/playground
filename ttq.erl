-module(ttq).

-export([add_offset/2, is_earlier_or_equal/2]).

% timestamp is {MegaSecs, Secs, MicroSecs} as elapsed time since 00:00 GMT, January 1, 1970 (zero hour)
-type timestamp() :: {non_neg_integer(), non_neg_integer(), non_neg_integer()}.  % {MegaSecs, Secs, MicroSecs}
-type offset_ms() :: non_neg_integer().  % MilliSecs


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

