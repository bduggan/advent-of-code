#!/usr/bin/env raku

sub wins($time,$distance) {
  sum (0^..^$time).map: -> \t {
    say "percent checked: " ~ (t / $time) * 100 if (t %% 1000000);
    ( $time - t ) * t > $distance ?? 1 !! 0;
  }
}

my @lines = lines().map: *.split(':')[1];
my (@times,@distances) := @lines».words;

# part 1
say [*] (@times Z=> @distances).map: { wins(.key,.value) }

# part 2
say wins(@times.join,@distances.join);

