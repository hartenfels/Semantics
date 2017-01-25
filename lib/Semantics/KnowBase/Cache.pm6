unit class Semantics::KnowBase::Cache;
use Semantics::KnowBase::Native;
use Semantics::KnowBase::Serialize;


has IO::Path:D $!kb-file    is required;
has IO::Path:D $!cache-file is required;

has %!cache;

my $need-stashing = SetHash.new;


submethod BUILD(:$!kb-file, :$cache-file) {
    $!cache-file = "$cache-file.$extension".IO;
    if $!cache-file.e && $!kb-file.modified < $!cache-file.modified {
        flocked $!kb-file, { %!cache = reconstitute(slurp $!cache-file) };
    }
}


method !store($key, $value) {
    %!cache\      {$key} = $value;
    $need-stashing{self} = True;
    return $value;
}


method get(&block, *@keys) {
    my $key = join '/', @keys;

    with %!cache{$key} {
        return $_;
    }
    else {
        return self!store($key, block());
    }
}


method get-many(&from-cache, &to-cache, &block, *@keys) {
    my $key = join '/', @keys;

    with %!cache{$key} {
        return map &from-cache, @$_;
    }
    else {
        my @result = block();
        self!store($key, [map &to-cache, @result]);
        return @result;
    }
}


method stash() {
    flocked $!kb-file, :exclusive, {
        $!cache-file.parent.mkdir;

        my %old;
        try do {
            if $!kb-file.modified < $!cache-file.modified {
                %old = reconstitute(slurp $!cache-file);
            }
        }

        my %combined = |%old, |%!cache;
        $!cache-file.spurt: conserve(%combined);
    };
}

END { .stash for $need-stashing.keys }
