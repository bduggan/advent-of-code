#!/usr/bin/env raku

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

$in = 'day-15.input'.IO.slurp;

class Sensor {
  has $.range;
  has $.position;
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
  say "added sensor at $position with range $range.  min x is $min-x, max is $max-x";
}
my $y = 2_000_000;
my $count = $max-x - $min-x;
my $done = 0;
{
	my $covered = 0;
	for $min-x .. $max-x -> $x {
    $done++;
    if ($done %% 10_000) {
      say "\rdone percent is : " ~ ($done / $count) * 100;
    }
		if %beacons{ "$x,$y" } {
			# $covered++;
			# print 'B';
			next;
		}
		my $sensed;
		for @sensors -> $sensor {
      if [ $x, $y ] eqv $sensor.position {
				# print 'S';
			  $sensed = True;
			  $covered++;
			  last;
			}
			if manhattan-distance( [ $x, $y ], $sensor.position ) <= $sensor.range {
				$covered++;
				# print '#';
				$sensed = True;
				last;
			}
		}
		# print '.' unless $sensed;
	}
  put "  $y: $covered";
}

#say "In row $y there are $covered positions where a beacon cannot be present";
