#!/usr/bin/env raku

sub intersection(\a, \va, \b, \vb) {
  # a
  # ma = va[1] / va[0]
  # a = (x1,y1) = (ax, ay)
  # point-slope
  # (y - y1) = m ( x - x1 )
  # y = m ( x - x1) + y1
  # y = ma ( x - ax) + ay
  # y = mb ( x - bx) + by

  # ma ( x - ax) + ay   = mb ( x - bx) + by
  # ma x - ma ax + ay   = mb x - mb bx + by
  # ma x - mb x         = ma ax - ay - mb bx + by
  # x (ma - mb)         = ma ax - mb bx - ay + by
  # x                   = ma ax - mb bx - ay + by / ( ma - mb )

  my \ma = va[1] / va[0];
  my \mb = vb[1] / vb[0];
  my (\ax, \ay) = a;
  my (\bx, \by) = b;

  my \x = ( ma * ax - mb * bx - ay + by ) / ( ma - mb );
  my \y  = ma * ( x - ax ) + ay;

  # [x, y] = ax, ay + t( vax, vay )
  # y = ay + t vay
  # y - ay = t vay
  # t = (y - ay) / vay
  my \ta = (y - ay) / va[1];
  fail "happened in the past for a { ta }" if ta < 0;
  my \tb = (y - by) / vb[1];
  fail "happened in the pbst for b { tb }" if tb < 0;
  return [ x, y ];
}

class Hailstone {
  has FatRat @.pos;
  has FatRat @.vel;
  method gist { @.pos.join(',') ~ ' @ ' ~ @.vel.join(',') }
}

#my $in = q:to/IN/;
#19, 13, 30 @ -2,  1, -2
#18, 19, 22 @ -1, -1, -2
#IN
my $in = 'input'.IO.slurp;

my @hailstones = $in.lines.map: {
  my ($pos, $vel) = .split('@');
  Hailstone.new(pos => $pos.split(',')[0,1]».FatRat, vel => $vel.split(',')[0,1]».FatRat);
}

my $count = 0;
my @bounds = 7, 27;
for @hailstones.combinations(2) -> ($a, $b) {
  say "\nHailstone A " ~ $a.gist;
  say "Hailstone B " ~ $b.gist;
  my $int;
  try { $int = intersection( $a.pos, $a.vel, $b.pos, $b.vel ); say $int; };
  if $int {
    if (@bounds[0] <= $int.all <= @bounds[1]) {
      $count++;
      say "inside: " ~ $int.raku;
    } else {
      say "outside: " ~ $int.raku;
    }
  } else {
    say "parallel";
  }
}

say "count $count";
