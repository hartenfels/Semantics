use Semantics <wine.rdf>;

subset Wine of Individual where * ⊑ <:Wine>;

sub to-maker(@source where { .all ~~ Wine }) {
    return unique map *.name, map |(* → <:hasMaker>), @source;
}

.say for sort to-maker query <:RedWine> ⊓ <:DryWine>;
