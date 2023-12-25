#!/usr/bin/env raku

sub intersection(\a, \va, \b, \vb) {
  my \ma = va[1] / va[0];
  my \mb = vb[1] / vb[0];
  my (\ax, \ay) = a;
  my (\bx, \by) = b;

  my \x = ( ma * ax - mb * bx - ay + by ) / ( ma - mb );
  my \y  = ma * ( x - ax ) + ay;
  my \ta = (y - ay) / va[1];
  fail "happened in the past for a { ta }" if ta < 0;
  my \tb = (y - by) / vb[1];
  fail "happened in the past for b { tb }" if tb < 0;
  return [ x, y ];
}

class Hailstone {
  has FatRat @.pos;
  has FatRat @.vel;
  method gist { @.pos.join(',') ~ ' @ ' ~ @.vel.join(',') }
}

my $in = 'input.real'.IO.slurp;

my @hailstones = $in.lines.map: {
  my ($pos, $vel) = .split('@');
  Hailstone.new(pos => $pos.split(',')[0,1]».FatRat,
                vel => $vel.split(',')[0,1]».FatRat
              );
}

my $count = 0;
my @bounds = 200000000000000, 400000000000000;

my $combos = @hailstones.combinations(2).elems;
for @hailstones.combinations(2) -> ($a, $b) {
  my $int;
  try {
    $int = intersection( $a.pos, $a.vel, $b.pos, $b.vel );
    my $str = $int.Str;
  };
  if $int {
    if (@bounds[0] <= $int.all <= @bounds[1]) {
      $count++;
    }
  }
}

say "count $count";
