#!/usr/bin/env raku

my @grid = lines.map: *.comb.list;
my @labeled = @grid.map: {  ( '.' xx .elems ).Array }

sub at(\r,\c) {
  .return with try @grid[r][c];
  '------';
}

my %shapes;
my %perimeters;

sub flood-fill(@in, \r, \c, $label) {
  return unless @labeled[r][c] && @labeled[r][c] eq '.';
  @labeled[r][c] = $label;
  %shapes{ $label }{ [r,c].raku } = 1;
  die "error" without at(r-1,c);
  if at(r-1,c) eq at(r,c) { flood-fill(@in,r-1,c, $label) } else { %perimeters{ $label }{ [r,c,'south'].raku } = 1 }
  if at(r+1,c) eq at(r,c) { flood-fill(@in,r+1,c, $label) } else { %perimeters{ $label }{ [r,c,'north'].raku } = 1 }
  if at(r,c-1) eq at(r,c) { flood-fill(@in,r,c-1, $label) } else { %perimeters{ $label }{ [r,c,'west'].raku } = 1 }
  if at(r,c+1) eq at(r,c) { flood-fill(@in,r,c+1, $label) } else { %perimeters{ $label }{ [r,c,'east'].raku } = 1 }
}

my $c = 0;

for @grid.kv -> \r, \row {
  for row.kv -> \c, \val {
    next if @labeled[r][c] ne '.';
    flood-fill(@labeled,r,c, @grid[r][c] ~ "-" ~ ++$c);
  }
}

my @all = unique @labeled.flatmap: { .list }
my $sum;
for @all -> $label {
  say "doing shape $label";
  my $area = %shapes{ $label }.keys.elems; 
  my $perim = %perimeters{ $label }.keys.elems; 
  $sum += $area * $perim;
}

say $sum;
