
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

${DIALYZER_PLT}:
	dialyzer --build_plt --output_plt $@ --apps erts kernel stdlib compiler crypto ${PROPER}/ebin

clean:
	rm *.beam
	rm test_report.txt

nuke: clean
	rm ${DIALYZER_PLT}
