#!/usr/bin/env raku

my @beams;
my $paths;
my $split-count;

for 'input'.IO.lines -> $l {
  my @row = $l.comb;
  @beams = @row.first(:k, { $_ eq 'S'}) if $l.contains('S');
  say "beams are at : " ~ @beams;
  my @splitters = @row.grep(:k, { $_ eq '^' } );
  next unless @splitters > 0;
  my %new-beams;
  my %s = set @splitters;
  my %once;
  for @beams -> $b {
    if %s{ $b } {
      $split-count++;
      %new-beams{ $b - 1 }++ unless %once{ $b - 1}++;
      %new-beams{ $b + 1 }++ unless %once{ $b + 1}++;
    } else {
      %new-beams{ $b }++ unless %once{ $b }++;
    }
  }
  @beams = %new-beams.keys.sort( +* );
  $paths +=%new-beams.values.sum;
  say "paths?" ~ %new-beams.values.sum;
}

say @beams;
say 'splits: ' ~ $split-count;
say "paths $paths";

