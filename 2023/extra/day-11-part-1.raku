#!/usr/bin/env raku

sub transpose(@m) {
  [Z] @m
}

sub dump(@rows) {
  .say for @rows.map: *.join;
  say '--';
}

sub double-blanks(@rows) {
  my @new;
  for @rows -> @r {
    @new.push: @r;
    next unless @r.unique.elems == 1;
    @new.push: @r;
  }
  @new;
}

my @m = 'input.real'.IO.slurp.lines.map: *.comb.Array;

my @n = double-blanks(@m);
my @o = transpose( double-blanks( transpose( @n ) ) );

my @galaxies;
for @o.kv -> $i, @row {
  for @row.kv -> $j, $c {
    next unless $c eq '#';
    @galaxies.push: ( $i, $j );
  }
}

my $sum;
for @galaxies.combinations(2) -> ($a,$b) {
  my $dist = abs($a[0] - $b[0]) + abs($a[1] - $b[1]);
  say ++$ ~ " pair $a $b, distance $dist";
  $sum += $dist;
}

say $sum;
