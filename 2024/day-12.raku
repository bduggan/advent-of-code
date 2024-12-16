#!/usr/bin/env raku

use Repl::Tools;
use Log::Async;

logger.send-to: $*ERR;

my @grid = lines.map: *.comb.list;
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

sub adjacent($x,$y) {
  my $a = $x.comb(/ [\d+ | \w+] /);
  my $b = $y.comb(/ [\d+ | \w+] /);
  return False unless $a[2] eq $b[2]; # direction
  return False unless $a[0] == $b[0] || $a[1] == $b[1]; # must be same row or col
  return False unless $a[0] == any($b[0] + 1, $b[0] - 1) || $a[1] == any($b[1] + 1, $b[1] - 1);
  return True;
}

sub calculate-number-of-sides($cells, $perim) {
  my $all-segments = $perim.SetHash;
  my @lines;
  loop {
    my $segment = $all-segments.grab or last;
    my @line-segments = $segment;
    my @neighbors = $all-segments.keys.grep( { adjacent( $_, $segment ) } );
    next if @neighbors == 0;
    die "bug" unless @neighbors == 1 | 2;
    while @neighbors {
      @line-segments.append: @neighbors;
      $all-segments = $all-segments (-) @neighbors;
      my @next;
      for @neighbors -> $n {
        @next.append: $all-segments.keys.grep( { adjacent( $_, $n ) } );
      }
      @neighbors = @next;
      die 'stuck' if ++$ > 50;
    }
    NEXT {
      @lines.push: %( :@line-segments );
    }
  }
  # say "lines: " ~ @lines.join("\n");
  return +@lines;
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
  info "doing shape $label " ~ (++$) ~ " of " ~ @all.elems;
  my $cells = %interior{ $label };
  my $area = $cells.keys.elems; 
  my $perim = %perimeters{ $label }.keys.elems; 
  # calculate the number of straight lines that are used to make the shape that is the perimeter
  # say "area: $area, segments: $perim";
  my $n = calculate-number-of-sides($cells, %perimeters{ $label }.keys);
  # say "NUMBER OF SIDES : $n";
  $sum += $area * $n;
}

say $sum;
