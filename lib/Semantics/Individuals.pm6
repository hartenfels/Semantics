unit class Semantics::Individuals;
use Semantics::KnowBase;


has Semantics::KnowBase:D $!kb is required;

submethod BUILD(:$!kb) {}


method AT-KEY(Str() $iri --> Semantics::KnowBase::Individual) {
    return $!kb.individual($iri);
}

method EXISTS-KEY(Str() $iri --> True) {}

method ASSIGN-KEY($) {
    die "can't assign to individuals";
}

method BIND-KEY($) {
    die "can't bind to individuals";
}
