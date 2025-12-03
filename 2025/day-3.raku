#!/usr/bin/env raku
unit sub MAIN($file = 'input');
my $tot;
for $file.IO.lines {
  my $max;
  my $len = .chars;
  my @nums = .comb;
  for (0..^$len).combinations(2) -> ($a,$b) {
    my $x = @nums[$a];
    my $y = @nums[$b];
    my $num = $x ~ $y;
    $max max= +$num;
  }
  say "for $_ max is $max";
  $tot += $max;
}
say $tot;


