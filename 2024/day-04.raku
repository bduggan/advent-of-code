#!/usr/bin/env raku

my @lines = lines;
my @rows = @lines.map: *.comb.list;
my @cols = ([Z] @rows)».join;

sub count(@lines) {
  sum @lines.map: { ( m:exhaustive/XMAS/ ).elems };
}

sub at(\i,\j) {
	try return @rows[i][j] // '';
  return '';
}

sub part-one {
  my $diags = 0;
  for @lines.kv -> \i, $row {
    for $row.comb.kv -> \j, $c {
      next unless at(i,j) eq 'X';
      $diags++ if at(i-1,j-1) eq 'M' and at(i-2,j-2) eq 'A' and at(i-3,j-3) eq 'S';
      $diags++ if at(i+1,j+1) eq 'M' and at(i+2,j+2) eq 'A' and at(i+3,j+3) eq 'S';
      $diags++ if at(i-1,j+1) eq 'M' and at(i-2,j+2) eq 'A' and at(i-3,j+3) eq 'S';
      $diags++ if at(i+1,j-1) eq 'M' and at(i+2,j-2) eq 'A' and at(i+3,j-3) eq 'S';
    }
  }
  say count(@lines) + count(@lines».flip)
    + count(@cols) + count(@cols».flip) + $diags;
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
