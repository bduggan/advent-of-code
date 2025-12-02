#!/usr/bin/env raku

sub is-repeater($num) {
  my $all = $num.comb.elems;
  for 1..5 -> $length {
    next unless $all %% $length;
    my @seqs = $num.comb($length);
    next unless @seqs > 1;
    return True if @seqs.unique == 1;
  }
  return False;
}

my $count;
my $sum = 0;
my @ranges = 'input.real'.IO.slurp.split(',');
for @ranges {
  my ($begin,$end) = .split('-').map: +*;
  say "$begin to $end";
  for $begin .. $end {
    next unless is-repeater($_);
    say "repeater: $_";
    $count++;
    $sum += $_;
  }
}

say "count is $count";
say "sum is $sum";
