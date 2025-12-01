#!/usr/bin/env raku

unit sub MAIN($file = 'input');

my $at = 50;
my $zeroes = 0;
my $passings = 0;
for $file.IO.lines {
  say "at $at and going $_";
  my $these-passings = 0;
  my $num = +.comb(/\d+/).join;
  my $dir = .comb(/L|R/);
  if $dir eq 'R' {
    $these-passings = ($at + ( $num - 1) ) div 100;
  } else {
    $these-passings = ($num - $at - 1 ) div 100 + 1;
  }
  if $these-passings {
    say "$_ and these passings is $these-passings";
  }
  $num *= -1 if $dir eq 'L';
  $at += $num;
  $at %= 100;
  $zeroes++ if $at == 0;
  $passings += $these-passings;
}

say "zero count: $zeroes";
say "passes count: $passings";
say "zero + passes: " ~ ($zeroes + $passings);
