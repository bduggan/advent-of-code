#!/usr/bin/env raku

my $in = q:to/IN/;
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
IN

$in = 'day-13.input'.IO.slurp;

use MONKEY-SEE-NO-EVAL;

multi infix:<mycmp>(Int $a,Int $b) {
  $a <=> $b;
}

multi infix:<mycmp>(Array $a, Array $b) {
  for @$a Z, @$b -> $pair {
    given $pair[0] mycmp $pair[1] {
      when Less { return Less }
      when More { return More }
    }
  }
  return Less if $a.elems < $b.elems;
  return Same if $a.elems == $b.elems;
  return More;
}

multi infix:<mycmp>(Array $a, Int $b) {
  return $a mycmp [ $b ];
}

multi infix:<mycmp>(Int $a, Array $b) {
  return [ $a ] mycmp $b;
}

sub str2data($str) {
 EVAL $str.subst(:g, "]", ",]").subst(:g, "[,]","[]");
}

# part 1
my $sum;
my $i = 0;
for $in.split("\n\n")».lines -> $pair {
  ++$i;
  my ($m1,$m2) = $pair.map: { str2data($_) }
  if ($m1 mycmp $m2) == Less {
    $sum += $i;
  }
}
say $sum;

# part 2
my @in = ($in ~ "\n[[2]]\n[[6]]\n").lines.grep(*.chars >  0).map: { str2data($_) };
my @sorted = @in.sort(&infix:<mycmp>);
my $first = 1 + @sorted.first: :k, { .raku eq '$[[2],]' };
my $second = 1 + @sorted.first: :k, { .raku eq '$[[6],]' };
say $first * $second;


