#!/usr/bin/env raku

use Repl::Tools;

my @grid = 'eg'.IO.lines.map: *.comb.list;
my @labeled = @grid.map: {  ( '.' xx .elems ).Array }

exit note "no grid" unless @grid.elems > 0;

sub at(\r,\c) {
  .return with try @grid[r][c];
  '------';
}

my %interior;
my %perimeters;

my %edge-groups;
my %grouped;
my @adjacent-pairs;

sub calculate-number-of-sides($cells, $perim) {
  my @p = $perim.clone.list;
  say "calculate perimeter, starting with " ~ @p.raku;
  for @p -> $candidate {
    my $try = $candidate.EVAL;
    my $match = @p.first: -> $p {
      my ( \r, \c, $dir) = $p.EVAL;
      (   ( $try[0] == r && $try[1] == ( (c + 1) | (c - 1) ) && $try[2] eq $dir )
       || ( $try[0] == ( ( r + 1 ) | (r - 1 ) ) && $try[1] == c && $try[2] eq $dir )
     ) # && ! (%grouped{ $try.raku }:exists );
    }
    next unless $match;
    say "found match $match matches $try";
    %grouped{ $match } = 1;
    @adjacent-pairs.push: [ $try, $match.EVAL ];
    say "iteration " ~ ++$;
  }
  say "orig: " ~ @p.raku;
  for @adjacent-pairs.sort.unique {
    say "pair : " ~ .raku;
  }
  say "adjacent-pairs " ~ @adjacent-pairs.unique.elems;
  repl;
}


sub flood-fill(@in, \r, \c, $label) {
  return unless @labeled[r][c] && @labeled[r][c] eq '.';
  @labeled[r][c] = $label;
  %interior{ $label }.push: [r,c];
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
  my $cells = %interior{ $label };
  my $area = $cells.keys.elems; 
  my $perim = %perimeters{ $label }.keys.elems; 
  # calculate the number of straight lines that are used to make the shape that is the perimeter
  say "area: $area, segments: $perim";
  calculate-number-of-sides($cells, %perimeters{ $label }.keys);
  $sum += $area * $perim;
}

say $sum;
