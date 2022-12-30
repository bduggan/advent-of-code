#!/usr/bin/env raku

use Repl::Tools;

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
my Hash @bps = $/.made;

my $robots = <ore>.Bag;
my $inv = BagHash.new;

my $until = 3;

sub possible-robots-to-buy(:$inv, :%bp) {
  # given a blueprint, return a list of possible robots to buy.
  # assumes max of one of each type of robot
  say "shopping for robots with " ~ $inv.kxxv;
  my @cart = ("none",); # buying nothing is an option
  for %bp.kv -> $robot, $cost {
    say "considering a $robot robot, it costs {$cost.Bag.kxxv} and we have {$inv.kxxv}";
    next unless $cost (<=) $inv;
    say "i can buy a $robot robot !";
    @cart.push: $robot;
  }
  say "returning cart: " ~ @cart.raku;
  @cart;
}

sub collect(:$minute is copy, BagHash :$inv is copy, Bag :$robots is copy, :$bp) {
  say "collecting at minute $minute, we have {$inv.raku}";
  return %( :$inv,:$robots ) if $minute == $until;
  $minute++;
  for $robots.keys -> $elt {
    my $qty = $robots{$elt};
    $inv{ $elt } += $qty;
    say $qty ~ " {$elt}-collecting robot collects $qty $elt; you now have {$inv{$elt}} $elt.";
  }
  # Now use inv to buy more robots
  my %best;
  my @opts = possible-robots-to-buy(:$inv, :$bp);
  for @opts -> $robot {
      my %got = collect(:$minute,
         inv => ($inv (-) $robot),
         robots => ( $robots (+) ($robot eq 'none' ?? Empty !! $robot) ),
         :$bp);
      %best = %got if !%best<geodes>.defined || %got<geodes> > %best<geodes> || %got.keys > %best.keys;
  }
  %best;
}

my %got = collect(:minute<1>, :$inv, :$robots, bp => @bps[0]);
say "done!";
say "remaining robots: { %got<robots>.raku }";
say "got { %got<inv>.raku }";

