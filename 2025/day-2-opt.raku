#!/usr/bin/env raku

my $sum = 0;
my @ranges = 'input'.IO.slurp.split(',');

for @ranges {

  my ($begin,$end) = .split('-').map: +*;

  for $begin .. $end {

    next unless .comb(
       ( 1..(.chars div 2) ).any
    ).unique == 1;

    $sum += $_;
  }
}

say "sum is $sum";
