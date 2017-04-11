unit class Semantics::KnowBase;
use JSON::Fast;
use X::Semantics;


class Knowledgeable {
    has Semantics::KnowBase:D $.kb  is required;
    has Any:D                 $.obj is required;

    multi method new($kb, $obj) { self.bless(:$kb, :$obj) }

    method Str(Knowledgeable:D: --> Str:D) { to-json($!obj, :!pretty) }
}


class Individual is Knowledgeable {
    method name(Individual:D: --> Str:D) {
        given self.obj {
            return ~$0 when /^.*? ':'    (.*)    $/;
            return ~$0 when /^'<' .* '#' (.*) '>'$/;
            return ~$0 when /^'<'        (.*) '>'$/;
            return $_;
        }
    }

    method Str(Knowledgeable:D: --> Str:D) { $.obj }

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


has $!path;
has $!socket;

submethod BUILD(:$!path, :$host = 'localhost', :$port = 53115) {
    $!socket = IO::Socket::INET.new(:$host, :$port, :nl-in("\n"));
}

method new(Str() $path --> Semantics::KnowBase:D) {
    return self.bless(:$path);
}


method !msg($op, $args) {
    $!socket.print(to-json([$!path, $op, $args], :!pretty) ~ "\n");
    my $res = from-json($!socket.get);
    die X::Semantics::Server.new(to-json($res)) if $res ~~ Hash;
    return $res
}


multi method atom(Atom:D $a --> Atom:D) { $a }
multi method atom(Str()  $s --> Atom:D) { Atom.new: self, ['r', $s] }

multi method concept(Concept:D  $c --> Concept:D) { $c }
multi method concept(Callable:D $b --> Concept:D) { Concept.new: self, ['O', $b()] }
multi method concept(Str()      $s --> Concept:D) { Concept.new: self, ['C', $s  ] }

multi method individual(Individual:D $i --> Individual:D) { $i }
multi method individual(Str()        $s --> Individual:D) {
    return Individual.new: self, self!msg: 'individual', $s;
}


method invert(Atom:D $a --> Atom:D) { Atom.new: self, ['i', $a.obj] }


method everything(--> Concept:D) { Concept.new: self, True  }
method nothing   (--> Concept:D) { Concept.new: self, False }

method unify(@cs --> Concept:D) {
    return Concept.new: self, ['U', [map *.obj, @cs]];
}

method intersect(@cs --> Concept:D) {
    return Concept.new: self, ['I', [map *.obj, @cs]];
}

method negate(Concept:D $c --> Concept:D) {
    return Concept.new: self, ['N', $c.obj];
}

method exists(Atom:D $a, Concept:D $c --> Concept:D) {
    return Concept.new: self, ['E', $a.obj, $c.obj];
}

method forall(Atom:D $a, Concept:D $c --> Concept:D) {
    return Concept.new: self, ['A', $a.obj, $c.obj];
}


method !individuals($arr) {
    return $arr.map: { Individual.new(self, $_) };
}

method satisfiable(Concept:D $c --> Bool:D) {
    return self!msg: 'satisfiable', $c.obj;
}

method query(Concept:D $c) {
    fail X::Semantics::Unsatisfiable.new($c) unless self.satisfiable($c);
    return self!individuals: self!msg: 'query', $c.obj;
}

method project(Individual:D $i, Atom:D $a) {
    return self!individuals: self!msg: 'project', [$i.obj, $a.obj];
}


method subtype(Concept:D $c, Concept:D $d --> Bool:D) {
    return self!msg: 'subtype', [$c.obj, $d.obj];
}

method member(Concept:D $c, Individual:D $i --> Bool:D) {
    return self!msg: 'member', [$c.obj, $i.obj];
}

method same(Individual:D $i, Individual:D $j --> Bool:D) {
    return self!msg: 'same', [$i.obj, $j.obj];
}
