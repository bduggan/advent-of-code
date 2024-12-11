#!/usr/bin/env raku

my $in = '0 4 4979 24 4356119 914 85734 698829';
my $times = 25;

my @nums = $in.words;

sub count-rocks($value, $times) {
  return 1 if $times == 0;
  if $value == 0 {
    return count-rocks(1, $times - 1) 
  }
  if $value.chars %% 2 {
      return
        count-rocks( +$value.substr(0, ($value.chars div 2)), $times - 1)
        + count-rocks( +$value.substr( ($value.chars div 2) ), $times - 1);
  }
  return count-rocks($value * 2024, $times - 1);
}

say sum $in.words.map: { count-rocks($_, $times) }
