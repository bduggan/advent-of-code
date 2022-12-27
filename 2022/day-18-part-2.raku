#!/usr/bin/env raku

use Sub::Memoized;

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

my $max = 0;
for @cubes {
  @taken[.[0];.[1];.[2]] = True;
  $max max= +.max;
}

sub reachable($x, :%seen = {}) is memoized {
  @*seen = %seen.keys;
  return False if %seen{$x.join(',')}++;
  return True if $x.any < 1;
  return True if $x.any > $max;
  for [0,0,1], [0,0,-1], [0,1,0], [0,-1,0], [1,0,0], [-1,0,0] {
    my $try = $x >>+>> $_;
    next if @taken[$try[0];$try[1];$try[2]];
    return True if reachable($try, :%seen);
  }
  False;
}

say "max is $max";
my $i = 0;
for 1..$max X 1..$max X 1..$max -> \g {
  say "doing " ~ ++$i ~ " of " ~ $max ** 3;
  next if @taken[ g[0]; g[1]; g[2] ];
  my @*seen;
  if !reachable(g) {
    @taken[ g[0]; g[1]; g[2] ] = True;
    for @*seen -> $mark {
      my \z = $mark.split(",");
      @taken[ z[0]; z[1]; z[2] ] = True;
    }
  }
}

my $sides;
for @cubes -> $cube {
  for [0,0,1], [0,0,-1], [0,1,0], [0,-1,0], [1,0,0], [-1,0,0] {
    my $check = $cube >>+>> $_;
    $sides++ unless @taken[ $check[0]; $check[1]; $check[2] ];
  }
}

say $sides;

