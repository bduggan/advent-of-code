#!/usr/bin/env raku
unit sub MAIN($file = 'input', $steps = 6);
use Repl::Tools;

my @grid = $file.IO.lines.map(*.comb.eager);
my \rows = @grid.elems;
my \cols = @grid[0].elems;

my %dist;

sub at(\row,\col) {
  return '#' unless 0 <= col < cols;
  return '#' unless 0 <= row < rows;
  @grid[row][col]
}

sub seen(\r,\c) {
  %dist{"{ r },{ c }"}:exists;
}

sub fill(@grid, $row, $col) {
 my @perimeter = [ ($row, $col), ];
 my $dist = 0;
 loop {
   say "---dist $dist, perimeter: " ~ @perimeter.elems;
   my @n;
   for @perimeter -> (\r, \c) {
     say "trying row { r }, col { c }";
     next if at(r,c) eq '#';
     if !seen(r, c+1) and at(r, c + 1) eq any('.','>') { @n.push: (r, c + 1) }
     if !seen(r, c-1) and at(r, c - 1) eq any('.','<') { @n.push: (r, c - 1) }
     if !seen(r+1, c) and at(r + 1, c) eq any('.','v') { @n.push: (r + 1, c) }
     if !seen(r-1, c) and at(r - 1, c) eq any('.'    ) { @n.push: (r - 1, c) }
   };
   #say "candidates: " ~ @n.raku;
   @perimeter = @n.unique(:as(*.join(',')));
   #say "new perimeter " ~ @perimeter.raku;
   %dist{ .join(',') } = $dist for @perimeter;
   last unless @perimeter;
   $dist++;
 }
}

my $row = @grid.first: :k, *.grep('S').elems;
my $col = @grid[$row].first: :k, * eq 'S';
say @grid[$row][$col];
say "dimensions: " ~ @grid.elems ~ 'x' ~ @grid[0].elems;
fill(@grid, $row, $col);

for @grid.kv -> $y, @row {
  for @row.kv -> $x, $cell {
    with %dist{"$x,$y"} {
      print .fmt(' [%02d] ');
    } else {
      print $cell.fmt(' [%2s] ');
    }
  }
  say '';
}

