unit module Semantics::KnowBase::Native;
use NativeCall;


class Obj is export is repr('CPointer') { ... }


sub have_jvm(--> int32) is native('semantics') { ... }

sub init_jvm(CArray[Str], int32, int32 is rw --> int32)
    is native('semantics') { ... }

sub init-jvm() is export {
    return False if have_jvm;

    my $dir    = $?FILE.IO.parent.parent.parent.parent;
    my $hermit = $dir.child('vendor').child('HermiT.jar').absolute;
    my $blib   = $dir.child('blib').absolute;

    my CArray[Str] $opts .= new;
    $opts[0] = "-Djava.class.path=$hermit\:$blib";

    my int32 $error;

    given init_jvm($opts, 1, $error) {
        when 0  { return True                            }
        when 1  { die "Can't set up JVM options: $error" }
        when 2  { die "Can't create JVM: $error"         }
        default { die "Unknown JVM init error: $error"   }
    }
}


sub root  (Obj --> Obj) is native('semantics') { ... }
sub unroot(Obj)         is native('semantics') { ... }

role Rooted is export {
    has Obj:D $.obj is required;

    submethod BUILD(:$obj) { $!obj = root($obj) }

    submethod DESTROY { unroot($!obj) }

    method Str () { ~$!obj }
    method gist() { ~$!obj }
}


class X::Java is export is Exception does Rooted {
    method message(--> Str) {
        return jcall(&o, 'getMessage', '()Ljava/lang/String;', self).as-str;
    }
}


sub check_exception(--> Obj) is native('semantics') { ... }

sub java(&block) {
    my $ret = block();
    if check_exception() -> $obj {
        die X::Java.new(:$obj);
    }
    return $ret;
}


sub s2j(blob16, uint32 --> Obj) is native('semantics') { ... }

multi sub to-obj(   Obj:D $_) {  $_  }
multi sub to-obj(Rooted:D $_) { .obj }
multi sub to-obj(   Str:D $_) {
    my $b = .encode('UTF-16');
    return java { s2j $b, $b.elems };
}

sub jcall(&func, Str() $name, Str() $sig, *@args) is export {
    return java { func($name, $sig, |map &to-obj, @args) };
}


sub init_knowbase(Obj --> Obj) is native('semantics') { ... }

sub new-knowbase(Str() $path) is export {
    init-jvm;
    return java { init_knowbase to-obj($path) };
}


sub b_o(Str, Str, Obj, Obj --> int32)
    is export is native('semantics') { ... }

sub o(Str, Str, Obj --> Obj)
    is export is native('semantics') { ... }

sub o_o(Str, Str, Obj, Obj --> Obj)
    is export is native('semantics') { ... }

sub o_oo(Str, Str, Obj, Obj, Obj --> Obj)
    is export is native('semantics') { ... }


sub j2s(Obj, & (uint32 --> blob16)) is native('semantics') { ... }

class Obj {
    method as-str() {
        my $buf;
        java &j2s.assuming: self, sub (uint32 $len --> blob16) {
            return $buf = blob16.new(0 xx $len);
        };
        return $buf.decode('UTF-16');
    }

    method Str() {
        return jcall(&o, 'toString', '()Ljava/lang/String;', self).as-str;
    }
}


sub a2j(Str, CArray[Obj], uint32 --> Obj) is native('semantics') { ... }

sub make-array($cls, @objs --> Obj) is export {
    my CArray[Obj] $arr .= new;

    for @objs.kv -> $i, $v {
        $arr[$i] = to-obj($v);
    }

    return java { a2j $cls, $arr, +@objs };
}


sub j2a(Obj, & (Obj)) is native('semantics') { ... }

sub get-array($arr, &block) is export {
    java { j2a $arr, &block };
    return;
}
