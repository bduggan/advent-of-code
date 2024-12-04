#!/usr/bin/env raku

my @lines = lines;
my @rows = @lines.map: *.comb.list;
my @cols = ([Z] @rows)».join;

sub at(\i,\j) {
  try return @rows[i][j] // '';
  return '';
}

sub x-mas(\i,\j,\dx,\dy) {
  'MAS' eq at( i + dx,     j + dy)
         ~ at( i + dx * 2, j + dy * 2)
         ~ at( i + dx * 3, j + dy * 3);
}

sub part-one {
  my $d = 0;
  for @lines.kv -> \i, \row {
    for row.comb.kv -> \j, \c {
      next unless c eq 'X';
      $d += x-mas(i, j, |@$_ ) for <-1 0 1> X, <-1 0 1>;
    }
  }
  say $d;
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
