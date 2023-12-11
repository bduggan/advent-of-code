#!/usr/bin/env raku

my @dir = lines().head.comb;
my regex node { <[A..Z]> ** 3 }
my %nodes;
for lines() {
  m/:s <node> '=' '(' <node> ',' <node> ')' / or next;
  %nodes{ $<node>[0] } = { L => $<node>[1], R => $<node>[2] };
}

my $node = 'AAA';
my $i = 0;
my $steps = 0;
loop {
  say "at node $node at step $steps" if ++$ %% 10_000;
  my $turn = @dir[$i];
  $i += 1;
  $steps += 1;
  $i %= @dir.elems;
  $node = %nodes{ $node }{ $turn };
  last if $node eq 'ZZZ';
}

say "steps $steps";
