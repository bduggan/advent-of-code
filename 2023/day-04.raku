#!/usr/bin/env raku

my ($sum, @copies);

for lines() {
   my ($card) = m/:s Card (\d+) ':' (.*) '|' (.*) $$/.Array;
   my $matches = +( (bag $1.words) ∩ bag $2.words );
   $sum += (2 ** ( $matches - 1 )).Int;
   @copies[ $card ^.. ($card + $matches) ]>>++ for 1..++@copies[$card];
}

# part 1, 2
say $sum, ',', @copies.sum;
