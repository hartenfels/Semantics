use v6;
use Test;
use Semantics::KnowBase;


throws-like { Semantics::KnowBase.new('nonexistent.rdf') }, X::Java,
            'nonexistent data source', message => /FileNotFound/;


isa-ok Semantics::KnowBase.new('share/music.rdf'),
       Semantics::KnowBase, 'proper data source';


done-testing;
