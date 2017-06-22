use v6;
use Test;
use Semantics <music.rdf>;


is I<:hendriks>, 'http://example.org/music#hendriks', 'known unprefixed';
is I<:whatever>, 'http://example.org/music#whatever', 'unknown unprefixed';

is I<what:ever>, 'what:ever', 'prefixed invidiual gets no URL';

is I<w:h:a:t:e*v-e_r>, 'w:h:a:t:e*v-e_r', 'nonsense IRIs work';

is I{''}, '', 'empty IRIs work, even if the syntax is weird';

is I<xs:string>, 'xs:string', "XML data types aren't special";


ok I<:hendriks>:exists, 'IRIs always exist';


dies-ok { I<:hendriks>  = ':hendriks' }, "can't assign to individuals";
dies-ok { I<:hendriks> := ':hendriks' }, "can't bind to individuals";


done-testing;
