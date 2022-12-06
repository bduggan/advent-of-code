#!/usr/bin/env raku

my $in = "mjqjpqmgbljsphdztnvjfqwrcgsmlb";
$in = 'day-06.input'.IO.slurp;

# part 1
say 4 + $in.comb.rotor(4 => -3).first: :k, { .unique.elems == 4  }

# part 2
say 14 + $in.comb.rotor(14 => -13).first: :k, { .unique.elems == 14  }
