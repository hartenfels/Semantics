use v6;
use Test;
use Semantics <share/music.rdf>;

constant $I = '["r",":influencedBy"]';
constant $S = '["C",":Song"]';


is ∃<:influencedBy> => T,       qq/["E",$I,true]/, '∃';
is ∀<:influencedBy> => <:Song>, qq/["A",$I,$S]/,   '∀';


done-testing;
