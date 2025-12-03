#!/usr/bin/env raku

my $sum = 0;
my @ranges = 'input'.IO.slurp.split(',');

for @ranges {

  my ($begin,$end) = .split('-').map: +*;

  $sum += sum ($begin .. $end).grep: {

    .comb(
       ( 1..(.chars div 2) ).any
    ).unique == 1;

  }
}

say "sum is $sum";
