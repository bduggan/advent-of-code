#!/usr/bin/env raku
unit sub MAIN($file = 'input', $steps = 6);

my @grid = $file.IO.lines.map(*.comb.eager);

my %dist;

sub fill(@grid, $row, $col) {
 my @perimeter = [ ($row, $col), ];
 my $dist = 0;
 loop {
   say "dist $dist, perimeter: " ~ @perimeter.elems;
   %dist{ .join(',') } = $dist for @perimeter;
   @perimeter = @perimeter.map: -> ($y, $x) { |( ($x - 1, $y), ($x + 1, $y), ($x, $y - 1), ($x, $y + 1) ) };
   @perimeter = @perimeter.grep: -> ($y, $x) {
     $x >= 0 and $y >= 0 and $x < @grid[0].elems and $y < @grid.elems and @grid[$y][$x] ne '#' and not %dist{"$y,$x"}:exists
   };
   @perimeter = @perimeter.unique(:as(*.join(',')));
   last unless @perimeter;
   $dist++;
 }
}

my $row = @grid.first: :k, *.grep('S').elems;
my $col = @grid[$row].first: :k, * eq 'S';
say @grid[$row][$col];
say "dimensions: " ~ @grid.elems ~ 'x' ~ @grid[0].elems;
fill(@grid, $row, $col);

my $sum = 0;
for @grid.kv -> $y, @row {
    for @row.kv -> $x, $cell {
        with %dist{"$x,$y"} {
          if $_ > $steps {
            print(' [  ] ');
          } elsif $_ == $steps {
            print(' [**] ');
            $sum++;
          } else {
            print .fmt(' [%02d] ');
            $sum++ if $_ %% 2;
          }
        } else {
          print $cell.fmt(' [%2s] ');
        }
    }
    say '';
}
say $sum;
