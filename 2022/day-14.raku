#!/usr/bin/env raku

my $in = q:to/IN/;
503,4 -> 502,4 -> 502,9 -> 494,9
498,4 -> 498,6 -> 496,6
IN

# $in = 'day-14.input'.IO.slurp;

my @grid;

sub draw {
  for @grid -> $row {
    say $row.map({$_ // '.'}).join;
  }
}

my $max-y = 0;
my $grains = 0;

for $in.lines {
  for .split(' -> ').rotor(2 => -1) -> ($from,$to) {
    my ($f,$t) = $from.split(','), $to.split(',');
    for (+$f[0] ... +$t[0]) X, (+$f[1] ... +$t[1]) -> ($x, $y) {
      @grid[ $y ; $x ] = '#';
      $max-y max= $y;
    }
  }
}

sub add-grain-of-sand($x, $y) {
  return False if $y >= $max-y + 2; # part 2
  for 0, -1, +1 -> $d {
    if (!defined( @grid[ $y + 1; $x + $d ])) {
      return True if add-grain-of-sand( $x + $d, $y + 1);
    }
  }
  return False if @grid[ $y; $x ];
  @grid[ $y; $x ] = 'o';
  $grains++;
  True;
}

loop {
  add-grain-of-sand(500,0) or last;
}
# draw;

say "grains : " ~ $grains;
