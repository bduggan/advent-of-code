#!/usr/bin/env raku

use Math::Interval;
my $in = 'input'.IO.lines;
my @have;

for $in<> -> $r {
  my ($x,$y) = $r.split('-');
  my $range = +$x .. +$y;
  @have.push: $range;
}

@have .= sort: { .min }
say @have;
