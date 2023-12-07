#!/usr/bin/env raku

enum types <
  HIGH-CARD ONE-PAIR TWO-PAIR THREE-OF-A-KIND
  FULL-HOUSE FOUR-OF-A-KIND FIVE-OF-A-KIND
>;

sub type($hand) {
  my @cards = $hand.comb;
  return FIVE-OF-A-KIND when (set @cards) == 1;
  return FULL-HOUSE when (bag @cards).values.sort.join eq '23';
  return FOUR-OF-A-KIND when (bag @cards).values.sort.join eq '14';
  return THREE-OF-A-KIND when (bag @cards).values.sort.join eq '113';
  return TWO-PAIR when (bag @cards).values.sort.join eq '122';
  return ONE-PAIR when (bag @cards).values.sort.join eq '1112';
  return HIGH-CARD;
}

my @vals = <2 3 4 5 6 7 8 9 T J Q K A>;
my %val = @vals.kv.reverse;

my @hands = 'input'.IO.lines.words.map: -> $hand, $bid { %( :$hand, :$bid ) };
my @sorted = @hands.sort:
   { (type($^a<hand>) <=> type($^b<hand>)) ||
            $^a<hand>.comb.map({%val{$_}}).join
        <=> $^b<hand>.comb.map({%val{$_}}).join
   }

say sum @sorted.map: { ++$ * .<bid> };
