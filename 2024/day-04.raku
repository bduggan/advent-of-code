#!/usr/bin/env raku

my @lines = lines;
my @rows = @lines.map: *.comb.list;
my @cols = ([Z] @rows)».join;

sub count(@lines) {
  sum @lines.map: { ( m:g/XMAS/ ).elems };
}

sub at(\i,\j) {
  try return @rows[i][j] // '';
  return '';
}

sub x-mas(\i,\j,\dx,\dy) {
  'MAS' eq
    at( i + dx,     j + dy)
  ~ at( i + dx * 2, j + dy * 2)
  ~ at( i + dx * 3, j + dy * 3);
}

sub part-one {
  my $d = 0;
  for @lines.kv -> \i, \row {
    for row.comb.kv -> \j, \c {
      next unless c eq 'X';
      $d += x-mas(i,j, +1, +1 ) + x-mas(i,j, -1, +1 )
          + x-mas(i,j, -1, -1 ) + x-mas(i,j, +1, -1 );
    }
  }
  say count(@lines) + count(@lines».flip)
    + count(@cols) + count(@cols».flip) + $d;
}

sub part-two {
  my $count = 0;
  for @lines.kv -> \i, $row {
    for $row.comb.kv -> \j, $c {
      next unless $c eq 'A';
      my @vals = at(i-1,j-1), at(i-1,j+1), at(i+1,j+1), at(i+1,j-1);
      $count++ if @vals.join eq <MMSS SSMM MSSM SMMS>.any;
    }
  }
  say $count;
}

part-one;
part-two;
