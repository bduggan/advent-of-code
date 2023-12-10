#!/usr/bin/env raku

my regex looptop { '┌' '─'* '┐' }
my regex loopbot { '└' '─'* '┘' }
my regex vert {
  | '└' '─'* '┐'
  | '┌' '─'* '┘'
  | '│'
}

my $count;
for 'path'.IO.lines {
  m/:s ^^ [ <looptop> | <loopbot> | <vert> ]* $$/ or say "no match '$_'";
  my @chars = .comb;
  my $total = 0;
  for $<vert>.Array -> $start,$end {
    my $sub = @chars[$start.from .. $end.from];
    $total += $sub.grep( * eq ' ').elems;
  }
  say $_ ~ ' ' ~ $total;
  $count += $total;
}

say $count;
 

