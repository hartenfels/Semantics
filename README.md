# NAME

Semantics — semantic data prototype for the [Software Languages Team](http://softlang.wikidot.com/) and [Institute for Web Science](https://west.uni-koblenz.de/lambda-dl) of the [University of Koblenz-Landau](https://www.uni-koblenz-landau.de/en/university-of-koblenz-landau)


# SYNOPSIS

```perl6
use Semantics <music.rdf>;

subset MusicArtist   of Individual  where * ⊑ <:MusicArtist>;
subset Influenceable of MusicArtist where * ⊑ ∃<:influencedBy> => ⊤;

sub get-influences(MusicArtist $artist) {
    given $artist {
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


# INSTALLATION

If you have [Docker](https://www.docker.com/), you can just run the
[container-semantics](container-semantics) script. It will pull the container
for you automatically, you don't need to install anything else.

For example:

```sh
./container-semantics examples/recommend.p6
```

If you don't want to use Docker, you need the following:

* Perl 6 - <http://rakudo.org/>

* Java JDK 8, shouldn't matter if it's Oracle or OpenJDK

* A Unix-like environment (C compiler, sh, make, perl)

To build it, first run `./configure` (which isn't autoconf). It should figure
out where all your JNI headers and libraries are. If it can't, follow the
instructions it gives to help it.

Then run `make` to build the Java and C libraries and run the tests and use the
`semantics` script that has been created for you:

```sh
./semantics examples/recommend.p6
```


# DESCRIPTION

This library implements semantic queries and types from
[λ-DL](https://west.uni-koblenz.de/lambda-dl) in Perl 6. It uses the Java-based
[HermiT](http://www.hermit-reasoner.com/) reasoner to deal with the semantic
queries, with a little C to make it callable via
[NativeCall](https://docs.perl6.org/language/nativecall).

To use this library, just `use` it with a path to a knowledge base file:

```perl6
use Semantics <music.rdf>;
```

This will export all the necessary operators and subroutines for the given
knowledge base file. The knowledge base instance will be cached, so repeated
invocations in different scopes will be compatible with each other.


## Operations

All of these operations are exported automatically.

Check out the [examples](examples) to see them in action.


### `I`

Lets you retrieve nominal semantic objects via associative subscript.  For
example, `I<:hendrix>` will give you an individual for the IRI `:hendrix`.


### `⊤` and `⊥`

Stand for everything and nothing. These are just terms that return the
appropriate object.


### `Concept`, `Atom`, `Individual`

These are aliases for the classes in
[Semantics::KnowBase](Semantics/KnowBase.pm6). Note that λ-DL calls it roles
instead of atoms, but since Perl 6 already has a completely different kind of
roles that seemed too confusing.


### `concept`, `atom`, `nominal`

```perl6
sub concept(   Concept:D|Str:D -->    Concept:D)
sub atom   (      Atom:D|Str:D -->       Atom:D)
sub nominal(Individual:D|Str:D --> Individual:D)
```

These subroutines all take either a [Str](https://docs.perl6.org/type/Str)ing
and return the appropriate Concept/Atom/Individual for it. If you hand them an
already instantiated object of the appropriate kind, that object is returned
instead.

You *usually* shouldn't have to use these manually. All the operators know what
kind of objects they expect, so they will call these functions automatically
for coercion.

Using `nominal(<:something>)` is the same as using `I<:something>`, but with
less sugar.


### Concept Operators

```perl6
sub infix:<⊓>(Concept:D|Str:D, Concept:D|Str:D --> Concept:D)
sub infix:<⊔>(Concept:D|Str:D, Concept:D|Str:D --> Concept:D)
```

Intersection and union of concepts.

These have list association, so `a ⊔ b ⊔ c` will build a single union of a, b
and c, not two pairwise unions.

Intersection binds tighter than union, as you'd hopefully expect.


```perl6
sub prefix:<¬>(Concept:D|Str:D --> Concept:D)
```

Negation of a concept, like `¬<:MusicArtist>`.


### Atom Operators

```perl6
sub postfix:<⁻>(Atom:D|Str:D --> Atom:D)
```

Inversion of an atom, like `<:influencedBy>⁻`.


### Quantification Operators

```perl6
sub prefix:<∃>((Atom:D|Str:D :key, Concept:D|Str:D :value) --> Concept:D)
sub prefix:<∀>((Atom:D|Str:D :key, Concept:D|Str:D :value) --> Concept:D)
```

Apply existential or universal quantification.

You use these operators with a pair, for example `∃<:influencedBy> => ⊤`.


### Type Membership

```perl6
sub infix:<⊑>(Individual:D|Str:D,    Concept:D|Str:D --> Bool:D)
sub infix:<⊒>(   Concept:D|Str:D, Individual:D|Str:D --> Bool:D)
```

Check if an individual belongs to a set of concepts, for example `I<:hendrix> ⊑
<:MusicArtist>`.

You can use these to build subset types for use as type constraints:

```perl6
subset MusicArtist   of Individual  where * ⊑ <:MusicArtist>;
subset Influenceable of MusicArtist where * ⊑ ∃<:influencedBy> => ⊤;
```


### Query

```perl6
query(Concept:D|Str:D $c --> Seq:D)
```

Executes a concept as a query against the knowledge base and returns a sequence
of individuals.

Note that the sequence itself doesn't have a type, only the individuals do:

```perl6
subset MusicArtist of Individual where * ⊑ <:MusicArtist>;

# WRONG: sub foo(MusicArtist @artists) { ... }

# Correct
sub foo(@artists where { .all ~~ MusicArtist }) { ... }
```


### Projection

```perl6
sub infix:<→>(Individual:D|Str:D, Concept:D|Str:D --> Seq:D)
```

Queries against an individual and returns a sequence of individuals. For
example, `<:hendrix> → <:influencedBy>`.

As with [queries](#query), only the individuals have a type, the sequence
itself does not.


# LICENSE

[Apache License, Version 2](LICENSE)


# SEE ALSO

* [λ-DL](https://west.uni-koblenz.de/lambda-dl)

* [LambdaDL](https://github.com/hartenfels/LambdaDL)

* [Semserv](https://github.com/hartenfels/Semserv)

* [HermiT](http://www.hermit-reasoner.com/)
