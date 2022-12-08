#!/usr/bin/env raku

my $in = q:to/IN/;
30373
25512
65332
33549
35390
IN

$in = 'day-08.input'.IO.slurp;

my @is-visible;
my @scenic-score;
my @forest = $in.lines».comb;

# count of trees less than or equal to a certain height
# (tighter precedence than times)
sub infix:<🌳>(@trees,\height --> Int:D) is tighter<*> {
  return 0 unless @trees > 0;
  my Int $score = @trees.first: :k, * >= height;
  return @trees.elems without $score;
  $score + 1;
}


# mark visibility left-right
for @forest.kv -> \row, @row {
  for @row.kv -> \i, \height {
    @is-visible[row;i] = @row[^i].all < height || @row[i^..*].all < height;
    @scenic-score[row;i] = [*] (@row[^i].reverse, @row[i^..*]) Z🌳 height xx *;
  }
}

# transpose, and check top to bottom
for ([Z] @forest).kv -> \col, @col {
  for @col.kv -> \i, \height {
    @is-visible[i;col] ||= @col[^i].all < height || @col[i^..*].all < height;
    @scenic-score[i;col] *= [*] (@col[^i].reverse, @col[i^..*]) Z🌳 height xx *;
  }
}

# part 1
say sum @is-visible.map( *.grep(so *).elems );

# part 2
say max @scenic-score.map: *.max;
