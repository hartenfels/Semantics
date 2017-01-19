use v6;
use Test;
use Semantics <share/music.rdf>;

my $A   = 'ObjectAllValuesFrom';
my $E   = 'ObjectSomeValuesFrom';
my $URL = 'http://example.org/music';


is ∃<:influencedBy> => T,       "$E\(<$URL#influencedBy> owl:Thing)",   '∃';
is ∀<:influencedBy> => <:Song>, "$A\(<$URL#influencedBy> <$URL#Song>)", '∀';


done-testing;
