#!/usr/bin/env raku

my $at = 50;
my $zeroes = 0;
my $passes = 0;
for 'input'.IO.lines {
  my $num = +.comb(/\d+/).join;
  my $dir = .comb(/L|R/);
  say "at $at, $_ -> $dir $num, passes $passes";
  $num *= -1 if $dir eq 'L';
  $at += $num;
  if ($at > 100 || $at < 0) {
    say "adding to passes because at is $at";
    $passes++ 
  }
  $at %= 100;
  if $at == 0 {
    say "adding to passes because at is 0";
    $passes++
  }
  $zeroes++ if $at == 0;
}

say "zero count: $zeroes";
say "passes count: $passes";
