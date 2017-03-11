#!/usr/bin/env __PERL6__
my $dir = $?FILE.IO.parent;
my $lib = $dir.child('lib').absolute;
exit run($*EXECUTABLE, "-I$lib", |@*ARGS).exitcode;
