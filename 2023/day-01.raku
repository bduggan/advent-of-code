#!/usr/bin/env raku

my $in = q:to/DONE/;
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
DONE

$in = 'input'.IO.slurp;

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
