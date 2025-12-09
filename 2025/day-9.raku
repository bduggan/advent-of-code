#!/usr/bin/env raku

unit sub MAIN($file = 'input');

my @pairs = $file.IO.slurp.lines.map: { [ .split(',') ] }

my @best = @pairs.combinations(2).max: by => -> ($a,$b) {
  abs ($a[0] - $b[0] + 1) * ($a[1] - $b[1] + 1)
}

say @best;

with @best[0] -> ($a,$b) {
  say $a;
  say $b;
  say abs ($a[0] - $b[0] + 1) * ($a[1] - $b[1] + 1)
}

