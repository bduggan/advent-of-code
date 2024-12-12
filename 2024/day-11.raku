#!/usr/bin/env raku

my $in = '125 17';
my $blinks = 25;

#my $in = '0 4 4979 24 4356119 914 85734 698829';

my @nums = $in.words;

my %known;

sub next-rock($r) {
  given $r {
    when 0 { 1 };
    when .chars %% 2 { [ +.substr(0, (.chars div 2) ), +.substr( (.chars div 2) ) ] }
    default { $_ * 2024 }
  }
}

sub transform-rocks($rocks) {
  my BagHash $next-bag;
  for $rocks.keys -> $rock {
    my $count = $rocks{ $rock };
    my $next = next-rock($rock);
    $next-bag{ $_ } += $count for $next.list;
  }
  return $next-bag.Bag;
}

my $rocks = bag $in.words;
for 1..25 {
  $rocks = transform-rocks($rocks);
}

say "total rocks in the bag are " ~ $rocks.values.sum;
