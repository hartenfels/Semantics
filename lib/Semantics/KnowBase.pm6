use Semantics::KnowBase::Cache;
use Semantics::KnowBase::Native;
use X::Semantics;
unit class Semantics::KnowBase is Rooted;


constant $K = 'LKnowBase;';
constant $S = 'Ljava/lang/String;';
constant $I = 'Lorg/semanticweb/owlapi/model/OWLNamedIndividual;';
constant $C = 'Lorg/semanticweb/owlapi/model/OWLClassExpression;';
constant $A = 'Lorg/semanticweb/owlapi/model/OWLObjectPropertyExpression;';


class Knowledgeable is Rooted {
    has Semantics::KnowBase:D $.kb  is required;
    has Str:D                 $.key is required;

    multi method new($kb, $key, Callable:D $builder) {
        return self.bless(:$kb, :$key, :$builder);
    }

    multi method new($kb, $key, $obj) {
        return self.bless(:$kb, :$key, :$obj);
    }

    method Str(Knowledgeable:D: --> Str:D) {
        $.kb.cache.get: { ~self.obj }, 'Str', $.key;
    }
}


sub id($kb, $obj) { jcall(&o_o, 'id', "($I)$S", $kb, $obj).as-str }

class Individual is Knowledgeable {
    method id(Individual:D: --> Str:D) {
        return $.kb.cache.get: { id($.kb, self) }, 'id', $.key;
    }

    method name(Individual:D: --> Str:D) {
        given self.id {
            return ~$0 when /^.*? ':'    (.*)    $/;
            return ~$0 when /^'<' .* '#' (.*) '>'$/;
            return ~$0 when /^'<'        (.*) '>'$/;
            return $_;
        }
    }

    method eqv(Individual:D: Individual:D $other --> Bool:D) {
        return $.kb === $other.kb && $.kb.same(self, $other);
    }
}

multi infix:<eqv>(Individual:D $i, Individual:D $j) is export { $i.eqv($j) }


class Atom is Knowledgeable {}


class Concept is Knowledgeable {
    multi method ACCEPTS(Concept:D: Concept:D $c) { $.kb.subtype: self, $c }
    multi method ACCEPTS(|)                       { callsame               }
}


has $.cache;

submethod BUILD(:$kb-file, :$cache-file) {
    $!cache = Semantics::KnowBase::Cache.new(:$kb-file, :$cache-file);
}

method new(Str() $path --> Semantics::KnowBase:D) {
    state %cache;
    my $abs = $path.IO.absolute.IO;
    return %cache{$abs} //= self.bless(
        builder    => { new-knowbase $abs },
        kb-file    => $abs,
        cache-file => "KBCACHE/{ $abs.basename }".IO,
    );
}


multi method atom(Atom:D $a --> Atom:D) { $a }
multi method atom(Str()  $s --> Atom:D) {
    return Atom.new: self, "Atom($s)", {
        jcall &o_o, 'atom', "($S)$A", self, $s;
    };
}

multi method concept(Concept:D $c --> Concept:D) { $c }
multi method concept(Str()     $s --> Concept:D) {
    return Concept.new: self, "Concept($s)", {
        jcall &o_o, 'concept', "($S)$C", self, $s;
    };
}

multi method nominal(Individual:D $i --> Individual:D) { $i }
multi method nominal(Str()        $s --> Individual:D) {
    return Individual.new: self, "Individual($s)", {
        jcall &o_o, 'nominal', "($S)$I", self, $s;
    };
}


method invert(Atom:D $a --> Atom:D) {
    return Atom.new: self, "⁻({ $a.key })", {
        jcall &o_o, 'invert', "($A)$A", self, $a;
    };
}


method everything(--> Concept:D) {
    return Concept.new: self, '⊤', { jcall &o, 'everything', "()$C", self };
}

method nothing(--> Concept:D) {
    return Concept.new: self, '⊥', { jcall &o, 'nothing', "()$C", self };
}

method unify(@cs --> Concept:D) {
    return Concept.new: self, "⊔({ @cs».key.join(',') })", {
        jcall &o_o, 'unify', "([$C)$C", self, make-array $C, @cs;
    };
}

method intersect(@cs --> Concept:D) {
    return Concept.new: self, "⊓({ @cs».key.join(',') })", {
        jcall &o_o, 'intersect', "([$C)$C", self, make-array $C, @cs;
    };
}

method negate(Concept:D $c --> Concept:D) {
    return Concept.new: self, "¬({ $c.key })", {
        jcall &o_o, 'negate', "($C)$C", self, $c;
    };
}

method exists(Atom:D $a, Concept:D $c --> Concept:D) {
    return Concept.new: self, "∃({ $a.key }.{ $c.key })", {
        jcall &o_oo, 'exists', "($A$C)$C", self, $a, $c;
    };
}

method forall(Atom:D $a, Concept:D $c --> Concept:D) {
    return Concept.new: self, "∀({ $a.key }.{ $c.key })", {
        jcall &o_oo, 'forall', "($A$C)$C", self, $a, $c;
    };
}


method !individuals(Obj:D $arr --> Array) {
    my @is;
    get-array $arr, -> Obj $obj {
        push @is, Individual.new: self, "Individual({ id(self, $obj) })", $obj;
    };
    return @is;
}

method satisfiable(Concept:D $c --> Bool:D) {
    return $!cache.get: {
        so jcall &b_o, 'satisfiable', "($C)Z", self, $c
    }, 'satisfiable', $c.key;
}

method query(Concept:D $c) {
    fail X::Semantics::Unsatisfiable.new($c) unless self.satisfiable($c);

    return $!cache.get-many: { self.nominal($_) }, *.id, {
        my $obj = jcall &o_o, 'query', "($C)[$I", self, $c;
        self!individuals: $obj;
    }, 'query', $c.key;
}

method project(Individual:D $i, Atom:D $a) {
    return $!cache.get-many: { self.nominal($_) }, *.id, {
        my $obj = jcall &o_oo, 'project', "($I$A)[$I", self, $i, $a;
        self!individuals: $obj;
    }, 'project', $i.key, $a.key;
}


method subtype(Concept:D $c, Concept:D $d --> Bool:D) {
    return $!cache.get: {
        so jcall &b_oo, 'subtype', "($C$C)Z", self, $c, $d;
    }, 'subtype', $c.key, $d.key;
}

method member(Concept:D $c, Individual:D $i --> Bool:D) {
    return $!cache.get: {
        so jcall &b_oo, 'member', "($C$I)Z", self, $c, $i;
    }, 'member', $c.key, $i.key;
}

method same(Individual:D $i, Individual:D $j --> Bool:D) {
    return $!cache.get: {
        so jcall &b_oo, 'same', "($I$I)Z", self, $i, $j;
    }, 'same', $i.key, $j.key;
}
