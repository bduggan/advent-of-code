#!/usr/bin/env raku

my $in = q:to/DONE/;
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
DONE

$in = 'input'.IO.slurp;

say sum $in.lines.map: {
  m:g/<[0..9]>/;
  $/[0,*-1].join;
}

