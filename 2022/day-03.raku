#!/usr/bin/env raku

my $in = q:to/IN/;
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
IN

$in = "day-03.input".IO.slurp;

my %vals = %( 'a'..'z' Z=> 1 .. 26 ), |%( 'A'..'Z' Z=> 27 .. 52 );

say sum
  $in.lines.map: -> $backpack {
    %vals{
      [∩] $backpack.comb[0 .. */2 - 1, */2 .. * ];
    }
  }

