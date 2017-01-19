use Semantics <share/wine.rdf>;

subset Wine of Individual where * ⊑ <:Wine>;


sub id(Individual $i) { "$i" ~~ /\#(.+)\>$/; ~$0 }

sub to-maker(@source where { .all ~~ Wine }) {
    return unique map *.&id, map |(* → <:hasMaker>), @source;
}


.say for sort to-maker map *.strip, query <:RedWine> ⊓ <:DryWine>;
