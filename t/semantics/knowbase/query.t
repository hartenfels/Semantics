use v6;
use Test;
use Semantics <music.rdf>;


subtest {
    my @artists = query <:MusicArtist>;
    cmp-ok @artists,      '==',  2,           'two artists returned';
    cmp-ok any(@artists), 'eqv', I<:beatles>, 'one of them is beatles';
    cmp-ok any(@artists), 'eqv', I<:hendrix>, 'the other is hendrix';
}, 'query for artists';


subtest {
    my @recorded = query(<:MusicArtist> ⊓ <:RecordedSong>);
    cmp-ok @recorded,    '==',  1,           'one artist returned';
    cmp-ok @recorded[0], 'eqv', I<:hendrix>, 'the artist is hendrix';
}, 'query for artists that recorded a song';


throws-like { query ⊥ }, X::Semantics::Unsatisfiable,
            'unsatisfiable query fails';

cmp-ok query(⊥), '~~', Failure, 'failure can be detected';


done-testing;
