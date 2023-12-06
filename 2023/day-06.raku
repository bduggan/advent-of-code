#!/usr/bin/env raku

sub wins($time,$distance) {
  my $wins;
  for 0^..^$time -> \t {
    $wins++ if ( $time - t ) * t > $distance;
    if (t %% 1000000) {
      say "percent checked: " ~ (t / $time) * 100;
    }
  }
  $wins;
}

my @wins;
my @lines = lines();

my @times = @lines[0].split(':')[1].words;
my @distances = @lines[1].split(':')[1].words;

# part 1
for @times Z, @distances -> ($time, $distance) {
  with wins($time,$distance) -> $w {
    @wins.push: $w
  }
}
say [*] @wins;

# part 2
say wins(@times.join,@distances.join);

