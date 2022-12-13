#!/usr/bin/env raku

my $in = 'day-13.input.example'.IO.slurp;

use MONKEY-SEE-NO-EVAL;

# pkt: compare packets

multi infix:<pkt>(Int $a,Int $b) {
  $a <=> $b;
}

multi infix:<pkt>(Array $a, Array $b) {
  for @$a Z, @$b {
    given .[0] pkt .[1] {
      .return when Less | More;
    }
  }
  $a.elems <=> $b.elems;
}

multi infix:<pkt>(Array $a, Int $b) {
  $a pkt [ $b ];
}

multi infix:<pkt>(Int $a, Array $b) {
  [ $a ] pkt $b;
}

sub str2data($str) {
 EVAL $str.subst(:g, "]", ",]").subst(:g, "[,]","[]");
}

# part 1
my @less = $in.split("\n\n")».lines.grep:
  :k, { str2data(.[0]) pkt str2data(.[1]) == Less };
say sum @less >>+>> 1;

# part 2
my @in = ($in ~ "\n[[2]]\n[[6]]\n").lines.grep(*.chars >  0).map: { str2data($_) };
my @sorted = @in.sort: &infix:<pkt>;
my $first = 1 + @sorted.first: :k, { .raku eq '$[[2],]' };
my $second = 1 + @sorted.first: :k, { .raku eq '$[[6],]' };
say $first * $second;

