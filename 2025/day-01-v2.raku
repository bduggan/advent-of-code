#!/usr/bin/env raku

unit sub MAIN($file = 'input');

my $passings = 0;

class Mover {
  has $.at is rw;
  method move-right(:$by!) {
    for 0..^$by {
      $!at++;
      $!at %= 100;
      $passings++ if $!at == 0;
    }
  }
  method move-left(:$by!) {
    for 0..^$by {
      $!at--;
      $!at = 99 if $!at == -1;
      $passings++ if $!at == 0;
    }
  }
}


my $m = Mover.new(:at<50>);

for $file.IO.lines {
  say "at {$m.at} and going $_";
  my $num = +.comb(/\d+/).join;
  my $dir = .comb(/L|R/);
  if $dir eq 'L' {
    $m.move-left: by => $num;
  } else {
    $m.move-right: by => $num;
  }
}

say "passes count: $passings";
