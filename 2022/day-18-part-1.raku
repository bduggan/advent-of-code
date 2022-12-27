#!/usr/bin/env raku

unit sub MAIN(Bool :$real);

my $in = q:to/IN/;
2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5
IN

$in = slurp 'day-18.input' if $real;

my @cubes = $in.lines.map: *.split(',');
my @taken;

for @cubes {
  @taken[.[0];.[1];.[2]] = True;
}

my $sides;
for @cubes -> $cube {
  for [0,0,1], [0,0,-1], [0,1,0], [0,-1,0], [1,0,0], [-1,0,0] {
    my $check = $cube >>+>> $_;
    $sides++ unless @taken[ $check[0]; $check[1]; $check[2] ];
  }
}

say $sides;

