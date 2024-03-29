#!/usr/bin/env raku

enum types <
  HIGH-CARD ONE-PAIR TWO-PAIR THREE-OF-A-KIND
  FULL-HOUSE FOUR-OF-A-KIND FIVE-OF-A-KIND
>;

sub type($hand) {
  my @cards = $hand.comb;
  given (bag @cards).values.sort.join {
    return FIVE-OF-A-KIND when '5';
    return FULL-HOUSE when '23';
    return FOUR-OF-A-KIND when '14';
    return THREE-OF-A-KIND when '113';
    return TWO-PAIR when '122';
    return ONE-PAIR when '1112';
  }
  return HIGH-CARD;
}

sub jtype($hand) {
  return FIVE-OF-A-KIND if type($hand) == FIVE-OF-A-KIND;
  my @cards = $hand.comb.grep: * ne 'J';
  return type($hand) if @cards == 5;
  if @cards == 4 {
    my @opts = @cards.join X~ @cards.unique;
    return max @opts.map: { type($_) }
  }
  my @vals = [X~] @cards.unique xx (5 - @cards);
  my @opts = @cards.join X~ @vals;
  max @opts.map: { type($_) }
}


my @hands = lines().words.map: -> $hand, $bid { %( :$hand, :$bid ) };

# part 1
my %val = <2 3 4 5 6 7 8 9 T J Q K A>.kv.reverse;
my @sorted = @hands.sort: { [ type($^a<hand>), |%val{ $^a<hand>.comb } ] }
say sum @sorted.map: { ++$ * .<bid> };

# part 2
my %jval = <J 2 3 4 5 6 7 8 9 T Q K A>.kv.reverse;
my @jsorted = @hands.sort: { [ jtype($^a<hand>), |%jval{ $^a<hand>.comb } ] }
say sum @jsorted.map: { ++$ * .<bid> };

