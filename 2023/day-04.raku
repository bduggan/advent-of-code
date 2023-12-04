say sum
 lines.map: {
   m/:s Card \d+ ':' (.*) '|' (.*) $$/;
   my $cnt = (bag $0.words) ∩ bag $1.words;
   (2 ** ($cnt.values - 1)).Int
}

  
