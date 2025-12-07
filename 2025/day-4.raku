#!/usr/bin/env raku

my @grid = 'input-4'.IO.lines.map: *.comb;

sub adjacent-vals($row,$col) {
  #say "checking $row, $col";
  my @offsets = ( (-1, 0, 1) X, (-1, 0, 1) ) .grep: { not (.[0] == 0 && .[1] == 0) }
  #say "offsets: " ~ @offsets.raku;
  my @positions = @offsets.map: { $_ >>+>> ($row,$col) };
  @positions .= grep: { 0 <= .[0] < @grid.elems && 0 <= .[1] < @grid[1].elems }
  #say "positions: " ~ @positions.raku;
  @positions.map: -> (\r,\c) { @grid[r][c] // die "out of bounds, row {r}, col {c}" }
}

my $ok;
for 0..^@grid.elems -> \r {
  for 0..^(@grid[0].elems) -> \c {
    next unless @grid[r][c] eq '@';
    my $count = + adjacent-vals(r,c).grep: { $_ eq '@' }
    say "checking row {r} col {c}, count is $count";
    $ok++ if $count < 4;
  }
}

say "ok: $ok";
