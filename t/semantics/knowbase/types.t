use v6;
use Test;
use Semantics <share/music.rdf>;


ok concept(<:MusicArtist>) ~~ concept(<:MusicArtist>),
   'same concept is subtype of itself';

nok concept(<:MusicArtist>) ~~ (∃<:influencedBy> => T),
    'not all music artists have influences';


is-deeply set(map * ⊑ ∃<:influencedBy> => T, query <:MusicArtist>),
          set(True, False), 'only some music artists have influences';


is-deeply set(map * ⊏ ∃<:influencedBy> => T, query <:MusicArtist>),
          set(False, False), 'query result subtype is more restricted';


is-deeply set(map { $_.strip ⊏ ∃<:influencedBy> => T }, query <:MusicArtist>),
          set(True, False), 'stripping the results works again';


sub get-influences($x where { $_ ⊏ ∃<:influencedBy> => T }) {
    return $x → <:influencedBy>;
}

lives-ok { get-influences  <:hendrix> }, 'getting influences for string';
lives-ok { get-influences I<:hendrix> }, 'getting influences for individual';

for query(<:MusicArtist>) -> $artist {
    dies-ok { get-influences $artist }, "getting influences for query dies";
}


done-testing;
