#!/usr/bin/env raku

my $in = q:to/IN/;
Blueprint 1:
  Each ore robot costs 4 ore.
  Each clay robot costs 2 ore.
  Each obsidian robot costs 3 ore and 14 clay.
  Each geode robot costs 2 ore and 7 obsidian.

Blueprint 2:
  Each ore robot costs 2 ore.
  Each clay robot costs 3 ore.
  Each obsidian robot costs 3 ore and 8 clay.
  Each geode robot costs 3 ore and 12 obsidian.
IN

grammar BP {
  rule TOP { <blueprint>+ }
  rule blueprint { Blueprint <num> ':' <robot>+ \s* \s* }
  token num { <[0..9]>+ }
  rule robot { Each <out=element> robot costs <qty> <in=element> [and <qty> <in=element>]? '.' }
  token element { ore | clay | obsidian | geode }
  token qty { <[0..9]>+ }
}

class BP::Actions {
  method TOP($/) {
    $/.make: [ $<blueprint>.map: *.made ];
  }
  method robot($/) {
    $/.make: %( "$<out>" => %( $<in>.list.map(~*) Z=> $<qty>.list.map(+*) ))
  }
  method blueprint($/) {
    $/.make: %( $<robot>.map: *.made )
  }
}

my $actions = BP::Actions.new;
BP.parse($in,:$actions) or die "parse failed";
my @bps = $/.made;

my $robots = <ore>.BagHash;
my $inv = BagHash.new;

my $minute = 1;
loop {
  say "-- Minute $minute --";
  for $robots.keys -> $elt {
    my $qty = $robots{$elt};
    $inv{ $elt } += $qty;
    say $qty ~ " {$elt}-collecting robot collects $qty $elt; you now have {$inv{$elt}} $elt.";
  }

  last if ++$ == 3;
  NEXT $minute++;
}

