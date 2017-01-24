my %exports;

module Semantics::JSON::Any {
    constant @MODULES = <
        JsonC
        JSON::Fast
        JSON::Tiny
        JSON5::Tiny
    >;

    for @MODULES {
        require ::($_) <&from-json &to-json>;
        %exports = (
            '&from-json' => &from-json,
            '&to-json'   => &to-json,
        );
        last;
        CATCH { next }
    }

    die 'No JSON module found in: ', @MODULES.join(', ') unless %exports;
}

sub EXPORT() { %exports }
