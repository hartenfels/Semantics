use Semantics::KnowBase::Native;
use X::Semantics;
unit class Semantics::KnowBase does Rooted;


constant $K = 'LKnowBase;';
constant $S = 'Ljava/lang/String;';
constant $I = 'Lorg/semanticweb/owlapi/model/OWLNamedIndividual;';
constant $C = 'Lorg/semanticweb/owlapi/model/OWLClassExpression;';
constant $A = 'Lorg/semanticweb/owlapi/model/OWLObjectPropertyExpression;';


role Knowledgeable is Rooted {
    has Semantics::KnowBase:D $.kb is required;

    method new($kb, $obj) { self.bless(:$kb, :$obj) }
}

class Atom    does Knowledgeable {}
class Concept does Knowledgeable {}

class Individual does Knowledgeable {
    method new($kb, $obj) { (state %cache){$obj} //= self.bless(:$kb, :$obj) }
}


method new(Str() $path --> Semantics::KnowBase:D) {
    state %cache;
    my $abs = $path.IO.absolute;
    return %cache{$abs} //= self.bless(:obj(new-knowbase $abs));
}


multi method atom(Atom:D $a --> Atom:D) { $a }
multi method atom(Str()  $s --> Atom:D) {
    my $obj = jcall &o_o, 'atom', "($S)$A", self, $s;
    return Atom.new: self, $obj;
}

multi method concept(Concept:D $c --> Concept:D) { $c }
multi method concept(Str()     $s --> Concept:D) {
    my $obj = jcall &o_o, 'concept', "($S)$C", self, $s;
    return Concept.new: self, $obj;
}

multi method nominal(Individual:D $i --> Individual:D) { $i }
multi method nominal(Str()        $s --> Individual:D) {
    my $obj = jcall &o_o, 'nominal', "($S)$I", self, $s;
    return Individual.new: self, $obj;
}


method invert(Atom:D $a --> Atom:D) {
    my $obj = jcall &o_o, 'invert', self, $a;
    return Atom.new: self, $a;
}


method everything(--> Concept:D) {
    my $obj = jcall &o, 'everything', "()$C", self;
    return Concept.new: self, $obj;
}

method nothing(--> Concept:D) {
    my $obj = jcall &o, 'nothing', "()$C", self;
    return Concept.new: self, $obj;
}

method unify(@cs --> Concept:D) {
    my $obj = jcall &o_o, 'unify', "([$C)$C", self, make-array $C, @cs;
    return Concept.new: self, $obj;
}

method intersect(@cs --> Concept:D) {
    my $obj = jcall &o_o, 'intersect', "([$C)$C", self, make-array $C, @cs;
    return Concept.new: self, $obj;
}

method negate(Concept:D $c --> Concept:D) {
    my $obj = jcall &o_o, 'negate', "($C)$C", self, $c;
    return Concept.new: self, $obj;
}

method exists(Atom:D $a, Concept:D $c --> Concept:D) {
    my $obj = jcall &o_oo, 'exists', "($A$C)$C", self, $a, $c;
    return Concept.new: self, $obj;
}

method forall(Atom:D $a, Concept:D $c --> Concept:D) {
    my $obj = jcall &o_oo, 'forall', "($A$C)$C", self, $a, $c;
    return Concept.new: self, $obj;
}


method !individuals(Obj:D $arr --> Array[Individual:D]) {
    my Individual:D @is;
    get-array $arr, -> Obj $obj { push @is, Individual.new: self, $obj };
    return @is;
}

method satisfiable(Concept:D $c --> Bool:D) {
    return so jcall &b_o, 'satisfiable', "($C)Z", self, $c;
}

method query(Concept:D $c --> Array[Individual:D]) {
    fail X::Semantics::Unsatisfiable.new($c) unless self.satisfiable($c);
    my $obj = jcall &o_o, 'query', "($C)[$I", self, $c;
    return self!individuals: $obj;
}

method project(Individual:D $i, Atom:D $a --> Array[Individual:D]) {
    my $obj = jcall &o_oo, 'project', "($I$A)[$I", self, $i, $a;
    return self!individuals: $obj;
}
