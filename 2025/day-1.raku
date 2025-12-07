#!/usr/bin/env raku

unit sub MAIN($file = 'input');

my $zeroes = 0;

for $file.IO.lines {
  my $num = +.comb(/\d+/).join;
  my $dir = .comb(/L|R/);
  $num *= -1 if $dir eq 'L';
  $at += $num;
  $at %= 100;
  $zeroes++ if $at == 0;
}

say "zero count: $zeroes";
