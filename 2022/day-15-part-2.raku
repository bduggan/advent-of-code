#!/usr/bin/env raku

use Log::Async;
logger.send-to($*ERR);

my $in = q:to/IN/;
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
IN

class Sensor {
  has $.range;
  has $.position;
  method Str { $.position.raku ~ " -> $.range" }
  method pos { $.position }
}

my regex num { '-'? <[0..9]>+ }
my regex coord { 'x=' <x=num> ', y=' <y=num> }
my regex line {:s 'Sensor at' <sensor=coord> ': closest beacon is at' <beacon=coord> }

sub manhattan-distance( $a, $b ) {
  abs($a[0] - $b[0]) + abs($a[1] - $b[1]);
}

my Sensor @sensors;
my %beacons;
my $min-x = Inf;
my $max-x = -Inf;

my $max-pos = 4_000_000;
$in = 'day-15.input'.IO.slurp;
# my $max-pos = 20;

for $in.lines {
  say "$_";
  /<line>/ or die "bad input";
  my $position = [ $<line><sensor><x y>.map: +* ];
  my $beacon = [ $<line><beacon><x y>.map: +* ];
  %beacons{ $beacon.join(',') } = True;
  my $range = manhattan-distance($position, $beacon);
  @sensors.push: Sensor.new: :$position, :$range;
  $min-x min= ($position[0] - $range);
  $max-x max= ($position[0] + $range);
}

sub found-it($x,$y) {
  return False if %beacons{ "$x,$y" };
  my $sensed = False;
  for @sensors -> $sensor {
    if [ $x, $y ] eqv $sensor.position {
      $sensed = True;
      last;
    }
    my $dist = manhattan-distance( [ $x, $y ], $sensor.position );
    if $dist <= $sensor.range  {
      $sensed = True;
      last;
    }
  }
  return !$sensed;
}

for @sensors -> $s {
  debug "checking sensor: $s";
  my @corners = $s.pos X>>+>> ( [0,$s.range + 1], [$s.range + 1,0],[ 0, - ( $s.range + 1 ) ],[-($s.range + 1), 0] );
  @corners.push: @corners[0];
  my @running;
  for @corners.rotor(2 => -1) -> ($from,$to) {
    @running.push: start {
      my $dist = manhattan-distance($from,$to);
      my $prog = 0;
      debug "checking side $from to $to ($dist)";
      for ( +$from[0] ... +$to[0] ) Z, ( +$from[1] ... +$to[1] ) -> ($x, $y) {
        $prog++;
        debug ($prog / $dist * 100) ~ ' percent ' if $prog %% 100_000;
        next unless 0 <= $y < $max-pos;
        next unless 0 <= $x < $max-pos;
        next unless found-it($x,$y);
        say "found a space at x = $x, y = $y";
        say "tuning freq is " ~ (4000000 * $x) + $y;
        exit;
      }
    }
  }
  await Promise.allof(@running);
}

