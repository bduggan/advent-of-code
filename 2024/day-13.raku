#!/usr/bin/env raku

my $in = slurp;

my @games = $in.split("\n\n");

# | 94 34 | x |80|  = | 8400 |
# | 22 67 |   |40|    | 5400 |
#
# invert matrix, then
# | 8400 | [M inverse ] = |80|
# | 5400 |                |40|

sub invert-matrix(@one,@two) {
  # invert the matrix with two rows
  my $det = @one[0] * @two[1] - @one[1] * @two[0];
  my @inv = (@two[1], -@one[1], -@two[0], @one[0]) >>/>> $det;
  return @inv;
}

use Repl::Tools;

sub game-cost($game) {
  my @a = $game.lines[0].comb(/\d+/);
  my @b = $game.lines[1].comb(/\d+/);
  my @price = $game.lines[2].comb(/\d+/) >>+>> @( 10000000000000, 10000000000000 );
  my @inverse = invert-matrix(@a,@b);
  my $a-count = @inverse[0] * @price[0] + @inverse[2] * @price[1];
  my $b-count = @inverse[1] * @price[0] + @inverse[3] * @price[1];
  return 0 unless $a-count.Int == $a-count;
  return 0 unless $b-count.Int == $b-count;
  say "got $a-count and $b-count";
  return $a-count * 3 + $b-count;
}

my $sum;
for @games {
  say "done with game " ~ ++$ ~ " of " ~ @games.elems;
  $sum += game-cost($_);
}
say $sum;


