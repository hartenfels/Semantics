use v6;
use Test;
use Semantics <share/music.rdf>;

constant $U   = 'ObjectUnionOf';
constant $I   = 'ObjectIntersectionOf';
constant $N   = 'ObjectComplementOf';
constant $URL = 'http://example.org/music';


is T, 'owl:Thing',   'T is ⊤';
is F, 'owl:Nothing', 'F is ⊥';


is <:MusicArtist> ⊔ <:Song>, "$U\(<$URL#MusicArtist> <$URL#Song>)", '⊔';
is <:MusicArtist> ⊓ <:Song>, "$I\(<$URL#MusicArtist> <$URL#Song>)", '⊓';
is ¬<:MusicArtist>,          "$N\(<$URL#MusicArtist>)",             '¬';


is <:MusicArtist> ⊔ ¬<:Song> ⊓ <:RadioStation>,
   "$U\(<$URL#MusicArtist> $I\(<$URL#RadioStation> $N\(<$URL#Song>)))",
   'precedence of ⊔, ⊓ and ¬';


is <:MusicArtist> ⊔ <:Song> ⊔ <:RadioStation>,
   "$U\(<$URL#MusicArtist> <$URL#RadioStation> <$URL#Song>)",
   'list association of ⊔';

is <:MusicArtist> ⊓ <:Song> ⊓ <:RadioStation>,
   "$I\(<$URL#MusicArtist> <$URL#RadioStation> <$URL#Song>)",
   'list association of ⊓';


done-testing;
