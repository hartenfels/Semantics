use v6;
use Test;
use Semantics <music.rdf>;

constant $I = '["r",":influencedBy"]';
constant $S = '["C",":Song"]';


is ∃<:influencedBy> => ⊤,       qq/["E",$I,true]/, '∃';
is ∀<:influencedBy> => <:Song>, qq/["A",$I,$S]/,   '∀';


done-testing;
