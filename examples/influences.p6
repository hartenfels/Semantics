use Semantics <music.rdf>;


subset MusicArtist   of Individual  where * ⊑ <:MusicArtist>;
subset Influenceable of MusicArtist where * ⊑ ∃<:influencedBy> => T;


sub get-influences(MusicArtist $artist) {
    given $artist {
        when Influenceable {
            my @influences = $_ → <:influencedBy>;
            return join ', ', map *.name, @influences;
        }
        default {
            return 'nobody';
        }
    }
}


for query <:MusicArtist> -> $artist {
    say $artist.name, ' influences: ', get-influences($artist), '.';
}
