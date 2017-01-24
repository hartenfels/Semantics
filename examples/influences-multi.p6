use Semantics <share/music.rdf>;


subset MusicArtist   of Individual  where * ⊑ <:MusicArtist>;
subset Influenceable of MusicArtist where * ⊑ ∃<:influencedBy> => T;


multi sub get-influences(Influenceable $artist) {
    my @influences = $artist → <:influencedBy>;
    return join ', ', map *.name, @influences;
}

multi sub get-influences(MusicArtist $) { 'nobody' }


for query <:MusicArtist> -> $artist {
    say $artist.name, ' influences: ', get-influences($artist), '.';
}
