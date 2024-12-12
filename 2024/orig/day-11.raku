#!/usr/bin/env raku

my $in = '125 17';

my @nums = $in.words;

sub count-rocks($value, $times) {
  return 1 if $times == 0;
  if $value == 0 {
    return count-rocks(1, $times - 1) 
  }
  if $value.chars %% 2 {
      return count-rocks( +$value.substr(0, ($value.chars div 2)), $times - 1)
           + count-rocks( +$value.substr( ($value.chars div 2) ), $times - 1);
  }
  return count-rocks($value * 2024, $times - 1);
}

my $times = 25;
say count-rocks(125, $times) + count-rocks(17, $times);
