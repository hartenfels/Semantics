use v6;
use Test;
use Semantics <share/music.rdf>;


subset MusicArtist   of Individual  where * ⊏ <:MusicArtist>;
subset Influenceable of MusicArtist where * ⊑ ∃<:influencedBy> => T;


sub get-influences(MusicArtist $artist) {
    given $artist {
        when Influenceable {
            my @influences = $_ → <:influencedBy>;
            return $_ => join ', ', @influences;
        }
        default {
            return $_ => 'nobody';
        }
    }
}


my %influences = map &get-influences, query <:MusicArtist>;


is %influences.keys.sort.join(','), I<:beatles :hendrix>.join(','),
   'correct keys for influences';

is %influences{I<:beatles>}, 'nobody',    'beatles have no influences';
is %influences{I<:hendrix>}, I<:beatles>, 'hendrix has beatles as influence';


done-testing;
