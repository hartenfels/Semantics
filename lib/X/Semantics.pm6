class X::Semantics is Exception {}


class X::Semantics::Server is X::Semantics {
    has $.message;

    method new($message) { self.bless(:$message) }
}


class X::Semantics::Unsatisfiable is X::Semantics {
    has $.concept;

    method new($concept) { self.bless(:$concept) }

    method message() { "unsatisfiable query: '$!concept'" }
}
