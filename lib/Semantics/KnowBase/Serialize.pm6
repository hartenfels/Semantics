my %exports;

module Semantics::KnowBase::Serialize {
    constant @MODULES = <
        JsonC
        JSON::Fast
        JSON::Tiny
        JSON5::Tiny
    >;

    for @MODULES {
        require ::($_) <&from-json &to-json>;
        %exports = (
            '$extension'    => 'json',
            '&reconstitute' => &from-json,
            '&conserve'     => &to-json,
        );
        last;
        CATCH { next }
    }

    unless %exports {
        require Semantics::KnowBase::Serialize::Eval <&reconstitute &conserve>;
        %exports = (
            '$extension'    => 'perl',
            '&reconstitute' => &reconstitute,
            '&conserve'     => &conserve,
        );
    }
}

sub EXPORT() { %exports }
