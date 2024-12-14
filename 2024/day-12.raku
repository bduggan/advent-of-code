#!/usr/bin/env raku

use Repl::Tools;

my @grid = 'eg'.IO.lines.map: *.comb.list;
my @labeled = @grid.map: {  ( '.' xx .elems ).Array }

exit note "no grid" unless @grid.elems > 0;

sub at(\r,\c) {
  .return with try @grid[r][c];
  '------';
}

sub partition-pairs(@pairs is copy) {
  my @groups;
  loop {
    my $next = @pairs.shift or last;
    my @overlaps = @pairs.grep: { .Set ∩ $next.Set > 0 }
    my @group = ($next, |@overlaps );
    @pairs = @pairs.grep: { .raku ∉ @overlaps.map: *.raku }
    loop {
      my @more-overlaps = @pairs.grep: -> $l { so @group.first( -> $g {$g.Set ∩ $l.Set}) };
      last unless @more-overlaps;
      @group.append: @more-overlaps;
      @pairs = @pairs.grep: { .raku ∉ @more-overlaps.map: *.raku }
      exit note 'nopt' if ++$ > 10;
    }
    @groups.push: @group;
  }
  return @groups;
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
     )
    }
    next unless $match;
    #say "found match $match matches $try";
    %grouped{ $match } = 1;
    @adjacent-pairs.push: [ $try, $match.EVAL ].sort.list;
  }
  my @partitioned = partition-pairs(@adjacent-pairs.map(*.raku));
  #repl;
  return @partitioned.elems;
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
  say "NUMBER OF SIDES : " ~ calculate-number-of-sides($cells, %perimeters{ $label }.keys);
  $sum += $area * $perim;
}

say $sum;
