#!/usr/bin/env raku

my @dir = lines().head.comb;
my regex node { <[A..Z0..9]> ** 3 }
my %nodes;
for lines() {
  next unless .chars > 0;
  m/:s <node> '=' '(' <node> ',' <node> ')' / or die "cannot match $_";
  %nodes{ $<node>[0] } = { L => $<node>[1], R => $<node>[2] };
}

sub steps-from($node is copy,$end) {
  my %seen;
  say "computing from $node to $end";
  my $i = 0;
  my $steps = 0;
  loop {
    return Inf if %seen{ $i }{ $node };
    %seen{ $i }{$node}++;
    my $turn = @dir[$i];
    $i += 1;
    $steps += 1;
    $i %= @dir.elems;
    $node = %nodes{ $node }{ $turn };
    last if $node eq $end;
  }

  return $steps;
}

my @starts = %nodes.keys.grep: *.ends-with('A');
my @ends = %nodes.keys.grep: *.ends-with('Z');

say "starts: " ~ @starts.join(',');
say "ends: " ~ @ends.join(',');

my @best;
for @starts -> $s {
  my @times = ($s X, @ends).map: -> ($s,$e) { steps-from($s,$e) }
  @best.push: @times.min;
}

say [lcm] @best;
