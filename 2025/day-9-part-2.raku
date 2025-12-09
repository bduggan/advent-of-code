#!/usr/bin/env raku

unit sub MAIN($file = 'input');

my @pairs = $file.IO.slurp.lines.map: { [ .split(',') ] }

my @grid;
sub fill-in-grid($a,$b) {
  say "fill in {$a.raku} to {$b.raku}";
  for ($a[0] ... $b[0]) -> $x {
    for ($a[1] ... $b[1]) -> $y {
      # say "filling in $x,$y";
      @grid[$x;$y] = True;
    }
  }
}

for @pairs.rotor(2 => -1) -> ($from,$to) { fill-in-grid($from,$to) }
fill-in-grid(@pairs[*-1],@pairs[0]);

sub count-filled($a,$b) {
  my $count = 0;
  for ($a[0] ... $b[0]) -> $x {
    for ($a[1] ... $b[1]) -> $y {
      $count++ if @grid[$x;$y];
    }
  }
  $count;
}

my @best = @pairs.combinations(2).max: by => -> ($a,$b) {
  count-filled($a,$b)
}

say @best;

with @best[0] -> ($a,$b) {
  say $a;
  say $b;
  say abs ($a[0] - $b[0] ) * ($a[1] - $b[1] )
}

