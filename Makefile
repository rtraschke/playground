
PROPER=../proper

DIALYZER_PLT=playground.plt
DIALYZER_RESULT=playground.dialyzed

ERL=erl
ERLFLAGS=-pa ${PROPER}/ebin

ERLC=erlc
ERLCFLAGS=+debug_info -I ${PROPER}/include -pa ${PROPER}/ebin

.SUFFIXES: .erl .beam

.erl.beam:
	${ERLC} ${ERLCFLAGS} $<

MODULES=ttq.erl ttq_eqc.erl


all: test_report.txt ${DIALYZER_RESULT}

test_report.txt: ${MODULES:.erl=.beam}
	@echo Running PropEr
	@${ERL} ${ERLFLAGS} -noshell -eval ' \
		{ok, F} = file:open("$@", [write]), \
		Failed_Spec_Cases = proper:check_specs(ttq, [{to_file, F}, long_result]), \
		Failed_Property_Cases = proper:module(ttq_eqc, [{to_file, F}, long_result]), \
		ok = file:close(F), \
		Status = case {Failed_Spec_Cases, Failed_Property_Cases} of \
			{[], []} -> \
				0; \
			{Failed_Spec_Cases, []} -> \
				io:format("Failed proper:check_specs: ~p~n", [Failed_Spec_Cases]), \
				1; \
			{[], Failed_Property_Cases} -> \
				io:format("Failed proper:module: ~p~n", [Failed_Property_Cases]), \
				1; \
			{Failed_Spec_Cases, Failed_Property_Cases} -> \
				io:format("Failed proper:check_specs: ~p~n", [Failed_Spec_Cases]), \
				io:format("Failed proper:module: ~p~n", [Failed_Property_Cases]), \
				1 \
		end, \
		halt(Status). \
	'

${DIALYZER_RESULT}: ${DIALYZER_PLT} ${MODULES:.erl=.beam}
	dialyzer --no_check_plt --plt ${DIALYZER_PLT} --output $@ --apps .


${MODULES:.erl=.beam}: ttq.hrl

${DIALYZER_PLT}:
	dialyzer --build_plt --output_plt $@ --apps erts kernel stdlib compiler crypto ${PROPER}/ebin

clean:
	rm -f ${MODULES:.erl=.beam} test_report.txt ${DIALYZER_RESULT} erl_crash.dump

nuke: clean
	rm -f ${DIALYZER_PLT}
