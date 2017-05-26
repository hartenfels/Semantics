use v6;
use Test;
use Semantics <music.rdf>;


ok concept(<:MusicArtist>) ~~ concept(<:MusicArtist>),
   'same concept is subtype of itself';

nok concept(<:MusicArtist>) ~~ (∃<:influencedBy> => T),
    'not all music artists have influences';


is-deeply set(map * ⊑ ∃<:influencedBy> => T, query <:MusicArtist>),
          set(True, False), 'only some music artists have influences';


sub get-influences($x where { $_ ⊑ ∃<:influencedBy> => T }) {
    return $x → <:influencedBy>;
}

lives-ok { get-influences  <:hendrix> }, 'lives with hendrix string';
lives-ok { get-influences I<:hendrix> }, 'lives with hendrix individual';

dies-ok  { get-influences  <:beatles> }, 'dies with beatles string';
dies-ok  { get-influences I<:beatles> }, 'dies with beatles individual';


ok query(∃<:influencedBy> => T).all ⊑ ∃<:influencedBy> => T,
   'correct query result for all elements';

nok query(<:MusicArtist>).all ⊑ ∃<:influencedBy> => T,
    'incorrect query result for all elements';


done-testing;
