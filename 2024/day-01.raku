#!/usr/bin/env raku

my $in = 'input'.IO.slurp;

my @a;
my @b;
for $in.lines.list {
  my $nums = .words;
  push @a, $nums[0];
  push @b, $nums[1];
}

sub part-one {
  my $sum;
  for ( @a.sort Z, @b.sort ) -> ($a,$b) {
    my $diff = abs($a - $b);
    $sum += $diff;
  }
  say $sum;
}

sub part-two {
  my $sum;
  for @a -> $a {
    my $count = @b.grep: * == $a;
    $sum += $count * $a;
  }
  say $sum;
}

