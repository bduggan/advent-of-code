#!/usr/bin/env raku

my $in = q:to/DONE/;
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
DONE

$in = 'input'.IO.slurp;

my $tot;

for $in.lines {
  m:g/<[0..9]>/;
  $tot += $0 ~ $/[*-1]
}

say $tot
