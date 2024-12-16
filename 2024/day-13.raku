#!/usr/bin/env raku

my $in = slurp;

my @games = $in.split("\n\n");

sub game-cost($game) {
  my @a = $game.lines[0].comb(/\d+/);
  my @b = $game.lines[1].comb(/\d+/);
  my @price = $game.lines[2].comb(/\d+/);
  my $min-cost = Inf;
  for 1..100 -> $a-count {
    for 1..100 -> $b-count {
      my @got = (@a >>*>> $a-count) >>+>> (@b >>*>> $b-count);
      next unless @got[0] == @price[0] && @got[1] == @price[1];
      #say "found $a-count and $b-count";
      my $cost = $a-count * 3 + $b-count;
      $min-cost = $cost if $cost < $min-cost;
    }
  }
  return 0 if $min-cost == Inf;
  $min-cost;
}

my $sum;
for @games {
  say "done with game " ~ ++$ ~ " of " ~ @games.elems;
  $sum += game-cost($_);
}
say $sum;


