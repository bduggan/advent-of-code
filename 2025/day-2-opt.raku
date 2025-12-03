#!/usr/bin/env raku

sub is-repeater($num) {
  return ( 1..($num.chars div 2) ).first: {
    $num.comb($_).unique == 1;
  }
}

my $sum = 0;
my @ranges = 'input'.IO.slurp.split(',');
for @ranges {
  my ($begin,$end) = .split('-').map: +*;
  for $begin .. $end {
    next unless is-repeater($_);
    $sum += $_;
  }
}

say "sum is $sum";
