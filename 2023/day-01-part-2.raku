#!/usr/bin/env raku

my $in = q:to/DONE/;
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
DONE

$in = 'input'.IO.slurp;

my @digits = <one two three four five six seven eight nine>;
my %vals = @digits Z=> 1..9;

say sum $in.lines.map: {
  m:ex/<[0..9]> | @digits/;
  ( $/[0, *-1].map: { %vals{ $_ } // $_ } ).join;
}
