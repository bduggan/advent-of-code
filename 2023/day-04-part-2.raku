my @copies;

for lines() {
   m/:s Card (\d+) ':' (.*) '|' (.*) $$/;
   my $card = $0;
   @copies[$card]++;
   my $cnt = (bag $1.words) ∩ bag $2.words;
   my $matches = $cnt.values.sum;
   for 1..@copies[$card] {
     @copies[$_]++ for $card ^.. ($card + $matches);
   }
}

say @copies.sum;
  
