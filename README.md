# NAME

Semantics — embedded semantic queries and types


# SYNOPSIS

```perl6
use Semantics <share/music.rdf>;

subset MusicArtist   of Individual  where * ⊑ <:MusicArtist>;
subset Influenceable of MusicArtist where * ⊑ ∃<:influencedBy> => T;

sub get-influences(MusicArtist $artist) {
    given $artist.strip {
        when Influenceable {
            my @influences = $_ → <:influencedBy>;
            return join ', ', @influences;
        }
        default {
            return 'nobody';
        }
    }
}

for query <:MusicArtist> -> $artist {
    say "$artist was influenced by ", get-influences($artist);
}
```


# REQUIREMENTS

* Perl 6 - <http://rakudo.org/>

* Java JDK 8, shouldn't matter if it's Oracle or OpenJDK

* A Unix-like environment (C compiler, sh, make, perl)


# BUILDING

First run `./configure` (which isn't autoconf). It should figure out where all
your JNI headers and libraries are. If it can't, follow the instructions it
gives to help it.

Then run `make` to build the Java and C libraries and run the tests.


# RUNNING

It is necessary to set up your environment's `LD_LIBRARY_PATH` and to include
[lib](lib) in Perl 6's library path. Since that's annoying to do manually,
`make` will generate a script called `semantics` that does this for you.

Simply run your Perl 6 scripts that `use Semantics` via:

```sh
./semantics yourprogram.p6
```


# LICENSE

[Apache License, Version 2](LICENSE)
