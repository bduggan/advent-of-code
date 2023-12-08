#!/usr/bin/env raku

my @dir = lines().head.comb;
my regex node { <[A..Z0..9]> ** 3 }
my %nodes;
for lines() {
  next unless .chars > 0;
  m/:s <node> '=' '(' <node> ',' <node> ')' / or die "cannot match $_";
  %nodes{ $<node>[0] } = { L => $<node>[1], R => $<node>[2] };
}

my @nodes = %nodes.keys.grep: *.ends-with('A');
my $i = 0;
my $steps = 0;
loop {
  say "at @node {@nodes.join(',')} at step $steps" if $++ %% 100_000;
  my $turn = @dir[$i];
  $i += 1;
  $steps += 1;
  $i %= @dir.elems;
  @nodes = %nodes{ @nodes }».{ $turn };
  last unless @nodes.first: { !.ends-with('Z') }
}

say "steps $steps";
