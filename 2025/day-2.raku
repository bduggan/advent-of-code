#!/usr/bin/env raku

sub is-repeater($num) {
  return False unless $num.comb.elems %% 2;
  my $els = $num.comb.elems div 2;
  my $first = $num.substr(0, $els );
  my $second = $num.substr( $els );
  return $first eq $second;
}

my $count;
my $sum = 0;
my @ranges = 'input.real'.IO.slurp.split(',');
for @ranges {
  my ($begin,$end) = .split('-').map: +*;
  say "$begin to $end";
  for $begin .. $end {
    next unless is-repeater($_);
    $count++;
    $sum += $_;
  }
}

say "count is $count";
say "sum is $sum";
