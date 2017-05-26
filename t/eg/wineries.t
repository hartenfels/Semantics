use v6;
use Test;
use Semantics <wine.rdf>;


subset Wine of Individual where * ⊑ <:Wine>;

sub to-maker(@source where { .all ~~ Wine }) {
    return unique map *.name, map |(* → <:hasMaker>), @source;
}

my @makers = sort to-maker query <:RedWine> ⊓ <:DryWine>;


is-deeply @makers, [<
    ChateauChevalBlanc
    ChateauLafiteRothschild
    ChateauMargauxWinery
    ChateauMorgon
    ClosDeVougeot
    Cotturi
    Elyse
    Forman
    GaryFarrell
    KathrynKennedy
    LaneTanner
    Longridge
    Marietta
    McGuinnesso
    MountEdenVineyard
    Mountadam
    PageMillWinery
    SantaCruzMountainVineyard
    SaucelitoCanyon
    SeanThackrey
    WhitehallLane
>], 'makers are correct';


done-testing;
