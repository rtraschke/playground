
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
	${ERL} ${ERLFLAGS} -noshell -eval 'proper:check_specs(ttq), proper:module(ttq_eqc), init:stop().' |tee $@

${DIALYZER_RESULT}: ${DIALYZER_PLT} ${MODULES:.erl=.beam}
	dialyzer --no_check_plt --plt ${DIALYZER_PLT} --output $@ --apps .


${MODULES:.erl=.beam}: ttq.hrl

${DIALYZER_PLT}:
	dialyzer --build_plt --output_plt $@ --apps erts kernel stdlib compiler crypto ${PROPER}/ebin

clean:
	rm -f *.beam test_report.txt ${DIALYZER_RESULT} erl_crash.dump

nuke: clean
	rm ${DIALYZER_PLT}
