use v6;
use Test;
use Semantics <wine.rdf>;

subset Wine   of Individual where * ⊑ <:Wine>;
subset Winery of Individual where * ⊑ <:Winery>;


sub get-wines(Winery $producer) { sort ~*, $producer → <:hasMaker>⁻ }

sub recommend-for(Wine $wine) {
    given $wine {
        when * ⊑ <:RedWine>   { '🍗' }
        when * ⊑ <:WhiteWine> { '🐟' }
        when * ⊑ <:RoseWine>  { '❓' }
        default { 'stay away!' }
    }
}


my %recommend = query(<:Winery>).sort(~*).map: -> $winery {
    my @wines = get-wines($winery);
    my $food  = @wines ?? recommend-for @wines[0] !! 'not a winery at all';
    $winery.name => $food
};


is-deeply %recommend, {
    Bancroft                  => '🐟',
    Beringer                  => 'not a winery at all',
    ChateauChevalBlanc        => '🍗',
    ChateauDYchem             => '🐟',
    ChateauDeMeursault        => '🐟',
    ChateauLafiteRothschild   => '🍗',
    ChateauMargauxWinery      => '🍗',
    ChateauMorgon             => '🍗',
    ClosDeLaPoussie           => '🐟',
    ClosDeVougeot             => '🍗',
    CongressSprings           => '🐟',
    Corbans                   => '🐟',
    CortonMontrachet          => '🐟',
    Cotturi                   => '🍗',
    DAnjou                    => '❓',
    Elyse                     => '🍗',
    Forman                    => '🍗',
    Foxen                     => '🐟',
    GaryFarrell               => '🍗',
    Handley                   => 'not a winery at all',
    KalinCellars              => '🐟',
    KathrynKennedy            => '🍗',
    LaneTanner                => '🍗',
    Longridge                 => '🍗',
    Marietta                  => '🍗',
    McGuinnesso               => '🍗',
    MountEdenVineyard         => '🐟',
    Mountadam                 => '🐟',
    PageMillWinery            => '🍗',
    PeterMccoy                => '🐟',
    PulignyMontrachet         => '🐟',
    SantaCruzMountainVineyard => '🍗',
    SaucelitoCanyon           => '🍗',
    SchlossRothermel          => '🐟',
    SchlossVolrad             => '🐟',
    SeanThackrey              => '🍗',
    Selaks                    => '🐟',
    SevreEtMaine              => '🐟',
    StGenevieve               => '🐟',
    Stonleigh                 => '🐟',
    Taylor                    => '🍗',
    Ventana                   => '🐟',
    WhitehallLane             => '🍗',
}, 'recommendations are correct';


done-testing;
