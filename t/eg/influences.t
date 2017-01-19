use v6;
use Test;
use Semantics <share/music.rdf>;


my %influences = map { $_ => $_ → <:influencedBy> }, query <:MusicArtist>;


is %influences.keys.sort.join(','), I<:beatles :hendrix>.join(','),
   'correct keys for influences';

is %influences{I<:beatles>}, (),          'beatles have no influences';
is %influences{I<:hendrix>}, I<:beatles>, 'hendrix has beatles as influence';


done-testing;
