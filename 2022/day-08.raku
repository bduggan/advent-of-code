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
sub infix:<🌳>(@trees,$height --> Int:D) is tighter<*> {
  return 0 unless @trees > 0;
  my Int $score = @trees.first: :k, * >= $height;
  return @trees.elems without $score;
  $score + 1;
}


# mark visibility left-right
for @forest.kv -> $row, @row {
  for @row.kv -> $index, $height {
    @is-visible[$row][$index] = so ( (@row[^$index]).all < $height or (@row[$index^..*]).all < $height );
    @scenic-score[$row][$index] = (@row[^$index]).reverse 🌳 $height * @row[$index^..*] 🌳 $height;
  }
}

# transpose, and check top to bottom
for ([Z] @forest).kv -> $col, @col {
  for @col.kv -> $index, $height {
    @is-visible[$index][$col] ||= so ( (@col[^$index]).all < $height or (@col[$index^..*]).all < $height );
    @scenic-score[$index][$col] *= (@col[^$index]).reverse 🌳 $height * @col[$index^..*] 🌳 $height;
  }
}

# part 1
say sum @is-visible.map( *.grep(so *).elems );

# part 2
say max @scenic-score.map: *.max;
