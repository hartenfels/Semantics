P6LIB = $(shell find lib -name '*.pm6')
TESTS = $(shell find t   -name '*.t'  )


all: Makefile semantics $(P6LIB) $(TESTS)
	make -s test


test:
	@echo -n 'Precompiling... '
	perl6 -Ilib -c lib/Semantics.pm6 && prove -j 9 -e 'perl6 -Ilib' -r t
	sleep 1


semantics: share/bin-template.p6
	perl -pe 's{__PERL6__}{perl6}g' <$< >$@
	chmod +x $@


clean:
	rm -rf lib/.precomp semantics

realclean: clean
	rm -rf Makefile


.PHONY: all test clean realclean
