#!/usr/bin/env raku

my $in = 'day-13.input.example'.IO.slurp;
$in = 'day-13.input'.IO.slurp;

use MONKEY-SEE-NO-EVAL;

# pkt: compare packets

multi infix:<pkt>(Int $a, Int $b) {
  $a <=> $b
}

multi infix:<pkt>(@a, @b) {
  (@a Zpkt @b).first(* != Same)
    or
  (@a.elems <=> @b.elems)
}

multi infix:<pkt>(@a, Int $b) {
  @a pkt [ $b ]
}

multi infix:<pkt>(Int $a, @b) {
  [ $a ] pkt @b
}

sub parse($str) {
 EVAL $str.subst(:g, "]", ",]").subst(:g, "[,]","[]")
}

# part 1
my @less = $in.split("\n\n")».lines.grep:
  :k, -> (\a, \b) { parse(a) pkt parse(b) == Less };
say sum @less »+» 1;

# part 2
my @in = ($in ~ "\n[[2]]\n[[6]]\n").lines.grep(so *).map: { parse($_) };
my @sorted = @in.sort: &infix:<pkt>;
my $first = 1 + @sorted.first: :k, { $_ eqv $[[2],] };
my $second = 1 + @sorted.first: :k, { $_ eqv $[[6],] };
say $first * $second;

