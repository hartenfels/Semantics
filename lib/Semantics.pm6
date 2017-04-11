use Semantics::KnowBase;
use Semantics::Individuals;


sub EXPORT(Str() $kb-path) {
    my Semantics::KnowBase $kb .= new($kb-path);

    sub atom      ($a) { $kb.atom:       $a }
    sub concept   ($c) { $kb.concept:    $c }
    sub individual($i) { $kb.individual: $i }

    sub project($i, $a) is looser(&infix:<+>) is assoc<none> {
        return $kb.project: $kb.individual($i), $kb.atom($a);
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

    sub member($i, $c) is looser(&infix:«=>») {
        return $kb.member: $kb.concept($c), $kb.individual($i);
    }

    sub superset($c, $i) is looser(&infix:«=>») {
        return $kb.member: $kb.individual($i), $kb.concept($c);
    }

    sub query($c) {
        return $kb.query: $kb.concept($c);
    }

    sub invert($a) {
        return $kb.invert: $kb.atom($a);
    }

    return {
        'I'            => Semantics::Individuals.new(:$kb),
        'T'            => $kb.everything,
        'F'            => $kb.nothing,
        '&concept'     => &concept,
        '&atom'        => &atom,
        '&individual'  => &individual,
        '&query'       => &query,
        '&infix:<→>'   => &project,
        '&infix:<⊔>'   => &unify,
        '&infix:<⊓>'   => &intersect,
        '&prefix:<¬>'  => &negate,
        '&prefix:<∃>'  => &exists,
        '&prefix:<∀>'  => &forall,
        '&postfix:<⁻>' => &invert,
        '&infix:<eqv>' => &infix:<eqv>,
        '&infix:<⊑>'   => &member,
        '&infix:<⊒>'   => &superset,
        'Atom'         => Semantics::KnowBase::Atom,
        'Concept'      => Semantics::KnowBase::Concept,
        'Individual'   => Semantics::KnowBase::Individual,
    };
}
