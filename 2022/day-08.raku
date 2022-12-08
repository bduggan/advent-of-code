#!/usr/bin/env raku

my $in = q:to/IN/;
30373
25512
65332
33549
35390
IN

$in = 'day-08.input'.IO.slurp;

my @forest = $in.lines».comb;
my @is-visible;
my @scenic-score;
my \N = @forest.elems - 1;

# count trees less than or equal to a certain height
sub infix:<🌳>(@trees,\height) {
  return $_ + 1 with @trees.first: :k, * >= height;
  @trees.elems
}

for 0..N X 0..N -> (\row, \col) {
  my \height = @forest[row;col];

  @is-visible[row;col] = [
    @forest[row;^col   ].all,
    @forest[row;col^..N].all,
    @forest[^row;col   ].all,
    @forest[row^..N;col].all
  ].any < height;

  @scenic-score[row;col] = [*] [
    @forest[row;^col   ].reverse,
    @forest[row;col^..N],
    @forest[^row;col   ].reverse,
    @forest[row^..N;col]
  ] X🌳 height
}

# part 1
say sum @is-visible.map( *.grep(so *).elems );

# part 2
say max @scenic-score.map: *.max;
