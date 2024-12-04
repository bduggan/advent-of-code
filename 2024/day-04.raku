#!/usr/bin/env raku

my @lines = lines;
my @rows = @lines.map: *.comb.cache;
my @cols = ([Z] @rows)>>.join;

sub show(@lines) {
  @lines.map: { ( m:exhaustive/XMAS/ ).elems };
}

sub count(@lines) {
  sum @lines.map: { ( m:exhaustive/XMAS/ ).elems };
}

sub at(\i,\j) {
  return '' if i < 0 || j < 0;
  return '' if i > @rows;
  return '' if j >= @rows[0];
  #die "out of range: { i } { j} " unless defined(@rows[i][j]);
  return @rows[i][j] // '';
}
my $diags = 0;

for @lines.kv -> \i, $row {
  for $row.comb.kv -> \j, $c {
    next unless at(i,j) eq 'A';
    my @vals = at(i-1,j-1), at(i-1,j+1), at(i+1,j+1), at(i+1,j-1);
    #                1           2            3           4
    #   1  2 
    #    A
    #   4  3
      
    $diags++ if @vals.join eq any(  'MMSS', 'SSMM', 'MSSM','SMMS' );
  }
}

say "diags: $diags";

exit;

say
 count(@lines) +
 count(@lines>>.flip) +
 count(@cols) +
 count(@cols>>.flip)
 + $diags;
 ;

