use v6;
use Test;
use Semantics <music.rdf>;


subset MusicArtist   of Individual  where * ⊑ <:MusicArtist>;
subset Influenceable of MusicArtist where * ⊑ ∃<:influencedBy> => T;


multi sub get-influences(Influenceable $artist) {
    my @influences = $artist → <:influencedBy>;
    return $artist => join ', ', @influences;
}

multi sub get-influences(MusicArtist $artist) {
    return $artist => 'nobody';
}


my %influences = map &get-influences, query <:MusicArtist>;


is %influences.keys.sort.join(','), I<:beatles :hendrix>.join(','),
   'correct keys for influences';

is %influences{I<:beatles>}, 'nobody',    'beatles have no influences';
is %influences{I<:hendrix>}, I<:beatles>, 'hendrix has beatles as influence';


done-testing;
