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

my $*tell-me-when-out = False;
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

sub steps-from(:$source where %valves, :$dest where %valves, :%seen is copy) {
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

my $*last-minute = 30;
sub total-pressure(Str :$at, Str :$elephant, :%open is copy, Int :$minute, :@instructions is copy, :@elephant-instructions is copy) {
  my $v = %valves{ $at };
  my @open = %open.keys.sort;
  my $pressure = %valves{ @open }.map(*.rate).sum;
  if $pressure > $global-max-pressure {
    say "achieved pressure at $minute : $pressure";
    $global-max-pressure = $pressure;
  }
  return 0 if $minute == $*last-minute + 1;
  # prune
  return 0 if $minute > 10 && $pressure < 50;
  return 0 if $minute > 15 && $pressure < 90;
  return 0 if $minute > 20 && $pressure < 110;

  if @open.elems == @nonzeros.elems {
    return $pressure + total-pressure(:$at, :%open, :minute($minute + 1));
  }

  if !@instructions && !@elephant-instructions {
    my @next = next-destinations($at,:%open,:$minute).List;
    my @next-elephant = next-destinations($elephant,:%open,:$minute).List;
    my @pressures;
    my %done;
    for @next X, @next-elephant -> ($next, $next-elephant) {
      next if $next eq $next-elephant;
      next if %done{$next}{$next-elephant} && $at eq $elephant;
      next if %done{$next-elephant}{$next} && $at eq $elephant;
      %done{$next-elephant}{$next} = True;
      %done{$next}{$next-elephant} = True;
      my @instructions = |steps-from(:source($at),:dest($next.label)).map({ :move($_) }), (:open($next.label));
      my @elephant-instructions = |steps-from(:source($elephant),:dest($next-elephant.label)).map({ :move($_) }), (:open($next-elephant.label));
      @pressures.push: total-pressure(:$at, :$elephant, :%open, :$minute, :@instructions, :@elephant-instructions);
    }
    if !%open{ $at } && %valves{ $at }.rate > 0 {
      @pressures.push: total-pressure(:$at, :$elephant, open => %open.clone.push($at => True), :minute($minute + 1));
    }
    if !%open{ $elephant } && %valves{ $elephant }.rate > 0 {
      @pressures.push: total-pressure(:$at, :$elephant, open => %open.clone.push($elephant => True), :minute($minute + 1));
    }
    return @pressures.max;
  }
  if !@instructions && @elephant-instructions {
    my @next = next-destinations($at,:%open,:$minute).List;
    my @pressures;
    for next-destinations($at,:%open,:$minute)<> -> $next {
      next if @elephant-instructions.grep( { $_ eqv :open($next) } );
      my @instructions = |steps-from(:source($at),:dest($next.label)).map({ :move($_) }), (:open($next.label));
      @pressures.push: total-pressure(:$at, :$elephant, :%open, :$minute, :@instructions, :@elephant-instructions);
    }
    if !%open{ $at } && %valves{ $at }.rate > 0 {
      @pressures.push: total-pressure(:$at, :$elephant, open => %open.clone.push($at => True), :minute($minute + 1));
    }
    return @pressures.max;
  }
  if @instructions && !@elephant-instructions {
    my @next-elephant = next-destinations($at,:%open,:$minute).List;
    my @pressures;
    for next-destinations($elephant,:%open,:$minute)<> -> $next-elephant {
      next if @instructions.first( { $_ eqv :open($next-elephant) } );
      my @elephant-instructions = |steps-from(:source($elephant),:dest($next-elephant.label)).map({ :move($_) }), (:open($next-elephant.label));
      @pressures.push: total-pressure(:$at, :$elephant, :%open, :$minute, :@instructions, :@elephant-instructions);
    }
    if !%open{ $elephant } && %valves{ $elephant }.rate > 0 {
      @pressures.push: total-pressure(:$at, :$elephant, open => %open.clone.push($elephant => True), :minute($minute + 1));
    }
    return @pressures.max;
  }

  my $do-it = @instructions.shift;
  my $do-elephant = @elephant-instructions.shift;
  %open{ $at } = True if $do-it.key eq 'open';
  %open{ $elephant } = True if $do-elephant.key eq 'open';
  my $new-at = $at;
  my $new-elephant = $elephant;
  if $do-it.key eq 'move' { $new-at = $do-it.value; }
  if $do-elephant.key eq 'move' { $new-elephant = $do-elephant.value; }
  return $pressure + total-pressure(:at($new-at), :elephant($new-elephant), :%open, :minute($minute + 1), :@instructions, :@elephant-instructions);
}

sub next-destinations($source,:%open,:$minute) {
  @nonzeros.grep: { .label ne $source && !%open{.label} }
}

multi MAIN('run', Bool :$real) {
  $*last-minute = 26;
  $in = 'day-16.input'.IO.slurp if $real;
  init;
  say total-pressure(:at<AA>, :elephant<AA>, :minute<1>);
}
