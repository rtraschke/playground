
PROPER=../proper

ERL=erl
ERLFLAGS=-pa ${PROPER}/ebin

ERLC=erlc
ERLCFLAGS=-I ${PROPER}/include -pa ${PROPER}/ebin

.SUFFIXES: .erl .beam

.erl.beam:
	export ERL_LIBS=${ERL_LIBS}
	${ERLC} ${ERLCFLAGS} $<

all: test_report.txt

test_report.txt: ttq.beam ttq_eqc.beam
	${ERL} ${ERLFLAGS} -noshell -eval 'proper:quickcheck(ttq_eqc:prop_add_offset()), proper:quickcheck(ttq_eqc:prop_is_earlier_or_equal()), init:stop().' |tee $@


clean:
	rm *.beam
	rm test_report.txt
