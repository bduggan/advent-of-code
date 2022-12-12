#!/usr/bin/env raku

my $in = q:to/IN/;
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
IN

$in = 'day-12.input'.IO.slurp;

my @grid = $in.lines.map: *.comb.Array;
my @distances = $in.lines.map: *.comb.map({my $}).Array;
my ($start,$end);
my @lowest;
for @grid.kv -> $row, @col {
  $start = %( :$row, col => $_ ) with @col.first(:k, { $_ eq 'S' });
  $end = %( :$row, col => $_ ) with @col.first(:k, { $_ eq 'E' });
  @lowest.push( %( :$row, col => $_) ) for @col.grep(:k, { $_ eq 'a' | 'S' });
}

sub set-distances(@frontier, $val) {
  for @frontier -> $p {
    @distances[ $p[0]; $p[1] ] = $val;
  }
  my @next;
  my %these;
  for @frontier X, (0,1), (0, -1), (1,0), (-1,0) -> ($current-coord, $next) {
     my ($row,$col) = $current-coord >>+>> $next;
     next unless 0 <= $row < @grid.elems;
     next unless 0 <= $col < @grid[0].elems;
     my $current-value = @grid[ $current-coord[0]; $current-coord[1] ];
     my $check = @grid[ $row; $col ];

     # height check
     next if $current-value eq 'E' && $check ne 'z';
     next if ($check ne 'S') && $current-value.ord > $check.ord + 1;

     next if defined( @distances[ $row; $col ] );
     next if %these{ $row }{ $col };
     @next.push: ($row,$col);
     %these{ $row }{ $col } = True;
  }
  return unless @next.elems > 0;
  set-distances(@next, $val + 1);
}

set-distances([ ( $end<row>, $end<col> ), ], 0);

# part 1
say @distances[ $start<row>; $start<col> ];

# part 2
say min @lowest.map: { @distances[ .<row>; .<col> ] }

