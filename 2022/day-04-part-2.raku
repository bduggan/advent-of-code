#!/usr/bin/env raku

my $in = q:to/IN/;
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
IN

$in = 'day-04.input'.IO.slurp;

my $covered = 0;
for $in.lines -> $pair {
  my ($first,$second) = $pair.split(',');
  my $first-range = Range.new(|( $first.split('-').map(+*) ));
  my $second-range = Range.new(|( $second.split('-').map(+*) ));
  if ($first-range ∩ $second-range).elems > 0 {
    $covered++ ;
  }
}

say $covered;

