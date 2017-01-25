unit module Semantics::KnowBase::Serialize::Eval;
use MONKEY-SEE-NO-EVAL;


sub reconstitute($text) is export {
    return EVAL $text;
}

sub conserve($stuff) is export {
    return $stuff.perl;
}


BEGIN {
    note 'Using .perl/EVAL for caching results.';
    note 'Please consider installing a JSON module instead.';
}
