my @copies;

for lines() {
   my ($card) = m/:s Card (\d+) ':' (.*) '|' (.*) $$/.Array;
   my $cnt = (bag $1.words) ∩ bag $2.words;
   my $matches = $cnt.values.sum;
   @copies[$card ^.. ($card + $matches)]>>++ for 1..++@copies[$card];
}

say @copies.sum;
