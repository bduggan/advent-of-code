#!/usr/bin/env raku

my $in = 'input'.IO.slurp;

my @grid = $in.lines.map: *.comb.list;
my \row-count = @grid.elems;
my \col-count = @grid[0].elems;

my %nines;

sub count-paths(\r,\c,$target = 0) {
  return 0 unless 0 <= r < row-count;
  return 0 unless 0 <= c < col-count;
  if @grid[r][c] != $target {
    return 0 
  }
  if $target == 9 {
    say "reached 9 at {r,c}";
    %nines{ $*start }{ "{r,c}" } = 1;
    return 1 
  }
  my @dirs = <0 1>, <0 -1>, <1 0>, <-1 0>;
  my $p = (r,c);
  my $next = @dirs »>>+<<» ($p, *);
  return sum $next.map: -> ($r,$c) { count-paths($r, $c, $target + 1) }
}

my $sum;
my $*start;
for @grid.kv -> \r, \row {
  for row.kv -> \c, \cell {
    next unless cell == 0;
    $*start = "{r,c}";
    say "counting paths from { r, c }";
    $sum += count-paths(r,c);
  }
}

say sum %nines.values.map: *.values.keys;
say "sum is $sum";

