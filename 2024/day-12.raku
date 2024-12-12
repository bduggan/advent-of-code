#!/usr/bin/env raku

my @grid = lines.map: *.comb.list;
my @labeled = @grid.map: {  ( '.' xx .elems ).Array }

sub at(\r,\c) {
  .return with try @grid[r][c];
  '------';
}

sub flood-fill(@in, \r, \c, $label) {
  say "filling row { r } col { c } with $label";
  return unless @labeled[r][c] && @labeled[r][c] eq '.';
  @labeled[r][c] = $label;
  die "error" without at(r-1,c);
  if at(r-1,c) eq at(r,c) { flood-fill(@in,r-1,c, $label) }
  if at(r+1,c) eq at(r,c) { flood-fill(@in,r+1,c, $label) }
  if at(r,c-1) eq at(r,c) { flood-fill(@in,r,c-1, $label) }
  if at(r,c+1) eq at(r,c) { flood-fill(@in,r,c+1, $label) }
}

my $c = 0;

for @grid.kv -> \r, \row {
  for row.kv -> \c, \val {
    next if @labeled[r][c] ne '.';
    flood-fill(@labeled,r,c, @grid[r][c] ~ "-" ~ ++$c);
  }
}

for @labeled {
  say .raku;
}
