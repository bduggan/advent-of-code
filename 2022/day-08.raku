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
my @score;

# count trees less than or equal to a certain height
sub infix:<🌳>(@trees,\height --> Int:D) is tighter<*> {
  return $_ + 1 with @trees.first: :k, * >= height;
  @trees.elems
}

# mark visibility left-right
for @forest.kv -> \row, @row {
  for @row.kv -> \i, \height {
    @is-visible[row;i] = [ @row[^i].all, @row[i^..*].all ].any < height;
    @score[row;i] = [*] [ @row[^i].reverse, @row[i^..*] ] X🌳 height
  }
}

# transpose, and check top to bottom
for ([Z] @forest).kv -> \col, @col {
  for @col.kv -> \i, \height {
    @is-visible[i;col] ||= [ @col[^i].all, @col[i^..*].all ].any < height;
    @score[i;col] *= [*] [ @col[^i].reverse, @col[i^..*] ] X🌳 height
  }
}

# part 1
say sum @is-visible.map( *.grep(so *).elems );

# part 2
say max @score.map: *.max;
