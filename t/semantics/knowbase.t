use v6;
use Test;
use Semantics::KnowBase;


my $zombie;

lives-ok { $zombie = Semantics::KnowBase.new('nonexistent.rdf') },
         "kb with nonexistent data source is too lazy to die right away";

throws-like { $zombie.obj }, X::Java, 'lazy kb dies when evaluated',
            message => /FileNotFound/;


isa-ok Semantics::KnowBase.new('share/music.rdf'),
       Semantics::KnowBase, 'proper data source';


done-testing;
