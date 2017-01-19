use Semantics <share/wine.rdf>;

subset Wine   of Individual where * ⊏ <:Wine>;
subset Winery of Individual where * ⊏ <:Winery>;


sub get-wines(Winery $producer) { $producer → <:hasMaker>⁻ }

sub recommend-for(Wine $wine) {
    given $wine {
        when * ⊑ <:RedWine>   { '🍗' }
        when * ⊑ <:WhiteWine> { '🐟' }
        when * ⊑ <:RoseWine>  { '❓' }
        default { 'stay away!' }
    }
}

sub id(Individual $i) { "$i" ~~ /\#(.+)\>$/; ~$0 }


for sort ~*, query <:Winery> -> $winery {
    my @wines = get-wines($winery);
    my $food  = @wines ?? recommend-for @wines[0] !! 'not a winery at all';
    printf "%25s: %s\n", id($winery), $food;
}
