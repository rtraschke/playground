
% timestamp is {MegaSecs, Secs, MicroSecs} as elapsed time since 00:00 GMT, January 1, 1970 (zero hour)
-type timestamp() :: {non_neg_integer(), non_neg_integer(), non_neg_integer()}.  % {MegaSecs, Secs, MicroSecs}
-type offset_ms() :: non_neg_integer().  % MilliSecs
