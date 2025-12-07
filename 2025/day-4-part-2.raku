#!/usr/bin/env raku

my @grid = 'in'.IO.lines.map: *.comb.Array;

sub adjacent-vals($row,$col) {
  my @offsets = ( (-1, 0, 1) X, (-1, 0, 1) ) .grep: { not (.[0] == 0 && .[1] == 0) }
  my @positions = @offsets.map: { $_ >>+>> ($row,$col) };
  @positions .= grep: { 0 <= .[0] < @grid.elems && 0 <= .[1] < @grid[1].elems }
  @positions.map: -> (\r,\c) { @grid[r][c] // die "out of bounds, row {r}, col {c}" }
}

sub remove-adjacents($row,$col) {
  my @offsets = ( (-1, 0, 1) X, (-1, 0, 1) ) .grep: { not (.[0] == 0 && .[1] == 0) }
  my @positions = @offsets.map: { $_ >>+>> ($row,$col) };
  @positions .= grep: { 0 <= .[0] < @grid.elems && 0 <= .[1] < @grid[1].elems }
  @positions.map: -> (\r,\c) { @grid[r][c] = 'x' }
}

my $all = 0;
loop {

  my $ok;
  my @remove-me;
  for 0..^@grid.elems -> \r {
    for 0..^(@grid[0].elems) -> \c {
      next unless @grid[r][c] eq '@';
      my $count = + adjacent-vals(r,c).grep: { $_ eq '@' }
      if $count < 4 {
        $ok++ ;
        @remove-me.push: (r,c);
      }
    }
  }
  last unless $ok;
  say "ok: $ok";
  last if $ok == 0;
  $all += $ok;
  for @remove-me {
    @grid[ .[0] ][ .[1] ] = 'x';
  }
}

say "sum $all";
