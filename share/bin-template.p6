#!/usr/bin/env __PERL6__
my $dir = $?FILE.IO.parent;

my $blib  = $dir.child('blib').absolute;
my @libs  = split ':', '__LIBPATH__';
my $p6lib = $dir.child('lib').absolute;

%*ENV<LD_LIBRARY_PATH> = join ':', $blib, |@libs, %*ENV<LD_LIBRARY_PATH> || ();
%*ENV<PERL6LIB>        = join ':', $p6lib,        %*ENV<PERL6LIB>        || ();

exit run($*EXECUTABLE, |@*ARGS).exitcode;