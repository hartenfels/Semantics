use v6;
use Test;
use Semantics <share/music.rdf>;

constant $M = '["C",":MusicArtist"]';
constant $R = '["C",":RadioStation"]';
constant $S = '["C",":Song"]';


is T, 'true',  'T is ⊤';
is F, 'false', 'F is ⊥';


is <:MusicArtist> ⊔ <:Song>, qq/["U",[$M,$S]]/, '⊔';
is <:MusicArtist> ⊓ <:Song>, qq/["I",[$M,$S]]/, '⊓';
is ¬<:MusicArtist>,          qq/["N",$M]/,      '¬';


is <:MusicArtist> ⊔ ¬<:Song> ⊓ <:RadioStation>,
   qq/["U",[$M,["I",[["N",$S],$R]]]]/,
   'precedence of ⊔, ⊓ and ¬';


is <:MusicArtist> ⊔ <:Song> ⊔ <:RadioStation>, qq/["U",[$M,$S,$R]]/,
   'list association of ⊔';

is <:MusicArtist> ⊓ <:Song> ⊓ <:RadioStation>, qq/["I",[$M,$S,$R]]/,
   'list association of ⊓';


done-testing;
