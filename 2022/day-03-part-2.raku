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

say sum $in.lines.rotor(3).map: -> $group {
  %vals{ [∩] $group.map(*.comb) }
}

