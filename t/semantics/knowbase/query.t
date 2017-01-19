use v6;
use Test;
use Semantics <share/music.rdf>;


cmp-ok set(query <:MusicArtist>), 'eqv', set(I<:beatles>, I<:hendrix>),
       'query for artists returns a set of them';


cmp-ok set(query <:MusicArtist> ⊓ <:RecordedSong>), 'eqv', set(I<:hendrix>),
       'query for artists that recorded a song';


throws-like { query F }, X::Semantics::Unsatisfiable,
            'unsatisfiable query fails';

cmp-ok query(F), '~~', Failure, 'failure can be detected';


done-testing;
