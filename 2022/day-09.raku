#!/usr/bin/env raku

my $in = q:to/IN/;
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
IN

$in = 'day-09.input'.IO.slurp;

my @seen;

my $size = 200;
my $start = 100;
my @knots = { :row($start), :col($start) } xx 10;
@seen[$start;$start] = 1;

sub move-head(%head, :dir($_)) {
  %head<col>-- when 'L';
  %head<col>++ when 'R';
  %head<row>++ when 'U';
  %head<row>-- when 'D';
}

my $total = 0;

# make one move to get tail closer to head.
sub move-tail(%head, %tail, Bool :$mark) {
  return if ((%head<col> - %tail<col>) & (%head<row> - %tail<row>)).abs <= 1;
  %tail<col> += (%head<col> <=> %tail<col>);
  %tail<row> += (%head<row> <=> %tail<row>);
  $total++ if $mark && !@seen[ %tail<row>; %tail<col> ]++;
}

for $in.lines -> $line {
  my ($dir,$n) = $line.split(' ');
  for 0..^$n {
	  move-head(@knots[0],:$dir);
    for @knots.rotor(2 => -1).kv -> $i, ($head,$tail) {
		  move-tail($head, $tail, mark => $i == @knots - 2);
		}
  }
}

say $total + 1;
