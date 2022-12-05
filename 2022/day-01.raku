#!/usr/bin/env raku

# usage: ./day-01.raku <input>

my $input = $*ARGFILES.slurp;

my $elves = $input.split("\n\n");
my @totals = $elves.map: *.lines.sum;

# part 1
put @totals.max;

# part 2
put @totals.sort.tail(3).sum;
