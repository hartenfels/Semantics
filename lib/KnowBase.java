import java.io.File;
import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;
import org.semanticweb.HermiT.Reasoner;
import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLNamedIndividual;
import org.semanticweb.owlapi.model.OWLObjectPropertyExpression;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.reasoner.NodeSet;


class KnowBase {
    private OWLDataFactory df;
    private OWLOntology    onto;
    private Reasoner       hermit;

    public KnowBase(String path) throws Exception {
        OWLOntologyManager mgr = OWLManager.createOWLOntologyManager();
        df     = mgr.getOWLDataFactory();
        onto   = mgr.loadOntologyFromOntologyDocument(new File(path));
        hermit = new Reasoner(onto);
    }


    private IRI toIRI(String s) {
        String expanded;
        try {
            expanded = hermit.getPrefixes().expandAbbreviatedIRI(s);
        }
        catch (IllegalArgumentException e) {
            expanded = s;
        }
        return IRI.create(expanded);
    }


    public OWLNamedIndividual nominal(String s) {
        return df.getOWLNamedIndividual(toIRI(s));
    }


    public OWLObjectPropertyExpression atom(String s) {
        return df.getOWLObjectProperty(toIRI(s));
    }

    public OWLObjectPropertyExpression invert(OWLObjectPropertyExpression a) {
        return df.getOWLObjectInverseOf(a);
    }


    public OWLClassExpression concept(String s) {
        return df.getOWLClass(toIRI(s));
    }

    public OWLClassExpression everything() {
        return df.getOWLThing();
    }

    public OWLClassExpression nothing() {
        return df.getOWLNothing();
    }


    public OWLClassExpression unify(OWLClassExpression[] cs) {
        return df.getOWLObjectUnionOf(cs);
    }

    public OWLClassExpression intersect(OWLClassExpression[] cs) {
        return df.getOWLObjectIntersectionOf(cs);
    }

    public OWLClassExpression negate(OWLClassExpression c) {
        return df.getOWLObjectComplementOf(c);
    }


    public OWLClassExpression exists(OWLObjectPropertyExpression a,
                                     OWLClassExpression          c) {
        return df.getOWLObjectSomeValuesFrom(a, c);
    }

    public OWLClassExpression forall(OWLObjectPropertyExpression a,
                                     OWLClassExpression          c) {
        return df.getOWLObjectAllValuesFrom(a, c);
    }


    public boolean satisfiable(OWLClassExpression c) {
        return hermit.isSatisfiable(c);
    }

    public boolean comparable(OWLClassExpression[] cs) {
        return satisfiable(intersect(cs));
    }

    public boolean same(OWLNamedIndividual i, OWLNamedIndividual j) {
        return hermit.isSameIndividual(i, j);
    }


    private OWLNamedIndividual[] individuals(NodeSet<OWLNamedIndividual> set) {
        return set.getFlattened().toArray(new OWLNamedIndividual[0]);
    }

    public OWLNamedIndividual[] query(OWLClassExpression c) {
        return individuals(hermit.getInstances(c, false));
    }

    public OWLNamedIndividual[] project(OWLNamedIndividual          i,
                                        OWLObjectPropertyExpression a) {
        return individuals(hermit.getObjectPropertyValues(i, a));
    }


    public boolean subtype(OWLClassExpression c, OWLClassExpression d) {
        OWLClassExpression e = df.getOWLObjectComplementOf(d);
        return  hermit.isEntailed(df.getOWLSubClassOfAxiom(c, d))
            && !hermit.isEntailed(df.getOWLSubClassOfAxiom(c, e));
    }

    public boolean member(OWLClassExpression c, OWLNamedIndividual i) {
        OWLClassExpression d = df.getOWLObjectComplementOf(c);
        return  hermit.isEntailed(df.getOWLClassAssertionAxiom(c, i))
            && !hermit.isEntailed(df.getOWLClassAssertionAxiom(d, i));
    }
}
