unit class Semantics::Nominals;
use Semantics::KnowBase;


has Semantics::KnowBase:D $!kb is required;

submethod BUILD(:$!kb) {}


method AT-KEY(Str() $iri --> Semantics::KnowBase::Individual) {
    return $!kb.nominal($iri);
}

method EXISTS-KEY(Str() $iri --> True) {}

method ASSIGN-KEY($) {
    die "can't assign to nominals";
}

method BIND-KEY($) {
    die "can't bind to nominals";
}
