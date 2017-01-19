use Semantics::KnowBase;
use Semantics::Nominals;


sub EXPORT(Str() $kb-path) {
    my Semantics::KnowBase $kb .= new($kb-path);

    sub project($i, $a) is looser(&infix:<+>) is assoc<none> {
        return $kb.project: $kb.nominal($i), $kb.atom($a);
    }

    sub unify(*@cs) is equiv(&infix:<+>) is assoc<list> {
        return $kb.unify: map { $kb.concept($_) }, @cs;
    }

    sub intersect(*@cs) is equiv(&infix:<*>) is assoc<list> {
        return $kb.intersect: map { $kb.concept($_) }, @cs;
    }

    sub negate($c) is equiv(&prefix:<!>) {
        return $kb.negate: $kb.concept($c);
    }

    sub exists((:key($a), :value($c))) is looser(&infix:«=>») {
        return $kb.exists: $kb.atom($a), $kb.concept($c);
    }

    sub forall((:key($a), :value($c))) is looser(&infix:«=>») {
        return $kb.forall: $kb.atom($a), $kb.concept($c);
    }

    sub query($c) {
        return $kb.query: $kb.concept($c);
    }

    sub invert($a) {
        return $kb.invert: $kb.atom($a);
    }

    return {
        'I'            => Semantics::Nominals.new(:$kb),
        'T'            => $kb.everything,
        'F'            => $kb.nothing,
        '&query'       => &query,
        '&infix:<→>'   => &project,
        '&infix:<⊔>'   => &unify,
        '&infix:<⊓>'   => &intersect,
        '&prefix:<¬>'  => &negate,
        '&prefix:<∃>'  => &exists,
        '&prefix:<∀>'  => &forall,
        '&postfix:<⁻>' => &invert,
    };
}
