#!/usr/bin/env raku

my $in = q:to/in/;
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
in

my $global-max-pressure = 0;

class Valve {
  has Str $.label;
  has Int $.rate;
  has Str @.tunnels;
  has Bool %!tunnels;
  has $.distance is rw;
  has $.score is rw;
  method TWEAK { %!tunnels = @.tunnels.map: { $_ => True }; }
  method gist { "valve $.label ($.rate) -> { @.tunnels.join(',') } (score: $.score)" }
  method Str { "valve $.label ($.rate)"; }
  method leads-to($dest) { %!tunnels{ $dest } or False }
}

my regex rate { <[0..9]>+ }
my regex label { <[A..Z]> ** 2 }
my regex line { :s Valve <this=label> has flow rate '=' <rate> ';' tunnel[s]? lead[s]? to valve[s]? <tunnel=label>+ % ', ' }

my %valves;
my @nonzeros;
sub init {
  for $in.lines {
    /<line>/ or die "bad parse: $_";
    $/ = $<line>;
    %valves{ ~$<this> } = Valve.new( label => ~$<this>, rate => +$<rate>, tunnels => $<tunnel>.map(*.Str) );
  }
  @nonzeros = %valves.values.grep: { .rate > 0 };
}

my %paths;

sub steps-from(:$source, :$dest, :%seen is copy) {
  return 'skip' if %seen{ $source }{ $dest };
  .return with %paths{ $source }{ $dest };
  return [ $dest ] if $source eq $dest;
  if %valves{ $source }.leads-to($dest) {
    %paths{ $source }{ $dest } = [ $dest ];
    return [ $dest ];
  }
  %seen{$source}{$dest} = True;
  my $best-path;
  for %valves{$source}.tunnels -> $t {
    my $path = steps-from(source => $t, :$dest, :%seen);
    next if $path eq 'skip'; # tried already
    if !$best-path || ($path.elems + 1 < $best-path.elems) {
      $best-path = [ $t, |@$path ];
    }
  }
  %paths{ $source }{ $dest } = $best-path;
  return $best-path // 'skip';
}

sub total-pressure(Str :$at, :%open is copy, Int :$minute, :@instructions is copy) {
  my $v = %valves{ $at };
  my @open = %open.keys.sort;
  my $pressure = %valves{ @open }.map(*.rate).sum;
  if $pressure > $global-max-pressure {
    say "achieved pressure at $minute : $pressure";
    $global-max-pressure = $pressure;
  }
  # d "minute $minute: we are at $at, valves open: {@open.elems} : { %open.keys.join(',') }, pressure: $pressure";
  return 0 if $minute == 31 ;
  if @open.elems == %valves.values.grep({.rate > 0}).elems {
    return $pressure + total-pressure(:$at, :%open, :minute($minute + 1));
  }
	if !@instructions {
		my @next = next-destinations($at,:%open,:$minute).List;
    my $max = 0;
    for @next -> $next {
      my @route := steps-from(:source($at),:dest($next.label));
      my @new-instructions = @route.map: { :move($_) };
      @new-instructions.push: (:open($next.label));
      $max max= total-pressure(:$at, :%open, :$minute, :instructions(@new-instructions));
    }
    unless %open{ $at } {
      $max max= total-pressure(:$at, open => %open.clone.push($at => True), :minute($minute + 1));
    }
    return $max;
  }
  my $do-it = @instructions.shift;
  # say "following instruction " ~ $do-it.raku;
  if $do-it.key eq 'open' {
    return $pressure + total-pressure(:$at, open => %open.clone.push($at => True), :minute($minute + 1), :@instructions);
  }
  my $next = $do-it.value;
  return $pressure + total-pressure(:at( $next ), :%open, :minute($minute + 1), :@instructions);
}

sub next-destinations($source,:%open,:$minute) {
  @nonzeros.grep: { .label ne $source && !%open{.label} }
}

multi MAIN('run', Bool :$real) {
  $in = 'day-16.input'.IO.slurp if $real;
  init;
  say total-pressure(:at<AA>, :minute<1>);
}
