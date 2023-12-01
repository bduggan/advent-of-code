#!/usr/bin/env raku

my $in = 'input'.IO.slurp;

# part 1
say sum $in.lines.map: {
  m:g/<[0..9]>/;
  $/[0,*-1].join;
}

# part 2
my @digits = <one two three four five six seven eight nine>;
my %vals = @digits Z=> 1..9;

say sum $in.lines.map: {
  m:ex/<[0..9]> | @digits/;
  ( $/[0, *-1].map: { %vals{ $_ } // $_ } ).join;
}
