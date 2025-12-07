#!/usr/bin/env raku

my %beams;

for 'input-real'.IO.lines.kv -> $rownum, $l {
  my @row = $l.comb;
  if $l.contains('S') {
    %beams = @row.first(:k, { $_ eq 'S'}) => 1;
  }
  my @splitters = @row.grep(:k, { $_ eq '^' } );
  my %new-beams;
  my %s = set @splitters;
  for %beams.keys -> $b {
    if %s{ $b } {
      %new-beams{ $b - 1 } += %beams{ $b };
      %new-beams{ $b + 1 } += %beams{ $b };
    } else {
      %new-beams{ $b } += %beams{ $b };
    }
  }
  %beams = %new-beams;
}

say "paths: " ~ %beams.values.sum;
