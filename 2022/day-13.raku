#!/usr/bin/env raku

my $in = 'day-13.input'.IO.slurp;

# ◆: compare packets

multi infix:<◆>(Int $a, Int $b) {
  $a <=> $b
}

multi infix:<◆>(@a, @b) {
  (@a Z◆ @b).first(* != Same)
    or
  (@a.elems <=> @b.elems)
}

multi infix:<◆>(@a, Int $b) {
  @a ◆ [ $b ]
}

multi infix:<◆>(Int $a, @b) {
  [ $a ] ◆ @b
}

sub parse($str) {
 use MONKEY-SEE-NO-EVAL;
 EVAL $str.subst(:g, "]", ",]").subst(:g, "[,]","[]")
}

# part 1
my @less = $in.split("\n\n")».lines.grep:
  :k, { parse(.[0]) ◆ parse(.[1]) == Less }
say sum @less »+» 1;

# part 2
my @in = ($in ~ "\n[[2]]\n[[6]]\n").lines.grep(so *).map: { parse($_) };
my @sorted = @in.sort: &infix:<◆>;
my $first = 1 + @sorted.first: :k, { $_ eqv $[[2],] };
my $second = 1 + @sorted.first: :k, { $_ eqv $[[6],] };
say $first * $second;

