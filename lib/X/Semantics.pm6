class X::Semantics is Exception {}


class X::Semantics::Unsatisfiable is X::Semantics {
    has $.concept;

    method new($concept) { self.bless(:$concept) }

    method message() { "unsatisfiable query: '$!concept'" }
}
