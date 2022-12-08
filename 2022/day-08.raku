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
sub infix:<🌳>(@trees,\height --> Int:D) is tighter<*> {
  return $_ + 1 with @trees.first: :k, * >= height;
  @trees.elems
}

for @forest.kv -> \row, @row {
  for @row.kv -> \i, \height {

    @is-visible[row;i] = [
      @row[^i]          .all,
      @row[i^..N]       .all,
      @forest[^row;i]   .all,
      @forest[row^..N;i].all
    ].any < height;

    @scenic-score[row;i] = [*] [
      @row[^i].reverse,
      @row[i^..*],
      @forest[^row;i].reverse,
      @forest[row^..N;i]
    ] X🌳 height
  }
}

# part 1
say sum @is-visible.map( *.grep(so *).elems );

# part 2
say max @scenic-score.map: *.max;
