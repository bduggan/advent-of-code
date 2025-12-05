#!/usr/bin/env raku

my ($ranges,$in) = 'input.real'.IO.slurp.split("\n\n");

my @fresh;
for $ranges.lines {
  my ($start,$end) = .split('-');
  @fresh.push: [ $start,  $end ];
}

my $count;
for $in.lines -> $ingredient {
  say "doing " ~ ++$ ~ " of " ~ $in.lines.elems;
  $count++ if @fresh.grep: -> $r { $r[0] <= $ingredient <= $r[1] }
}

say @fresh.raku;
say $count;
