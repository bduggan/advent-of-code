#!/usr/bin/env raku

my @beams;
my $split-count;

for 'input-real'.IO.lines -> $l {
  my @row = $l.comb;
  @beams = @row.first(:k, { $_ eq 'S'}) if $l.contains('S');
  say "beams are at : " ~ @beams;
  my @splitters = @row.grep(:k, { $_ eq '^' } );
  next unless @splitters > 0;
  my %new-beams;
  my %already-counted;
  my %s = set @splitters;
  for @beams -> $b {
    if %s{ $b } {
      %new-beams{ $b - 1 } = True;
      %new-beams{ $b + 1 } = True;
      $split-count++ unless %already-counted{ $b }++;
    } else {
      %new-beams{ $b } = True;
    }
  }
  @beams = %new-beams.keys.sort( +* );
}

say @beams;

say $split-count;

