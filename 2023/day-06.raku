#!/usr/bin/env raku

sub wins($time,$distance) {
  my $wins;
  for 0^..^$time -> \t {
    $wins++ if ( $time - t ) * t > $distance;
  }
  $wins;
}

my @wins;
my @lines = lines();
my @times = @lines[0].split(':')[1].words;
my @distances = @lines[1].split(':')[1].words;
for @times Z, @distances -> ($time, $distance) {
  say "time $time, distance $distance";
  with wins($time,$distance) -> $w {
    say "wins: $w";
    @wins.push: $w
  }
}

say [*] @wins



