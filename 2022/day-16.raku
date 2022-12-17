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

$in = 'day-16.input'.IO.slurp;

class Valve {
  has Str $.label;
  has Int $.rate;
  has Str @.tunnels;
  has Bool %!tunnels;
  has $.distance is rw;
  has $.score is rw;
  method TWEAK {
    %!tunnels = @.tunnels.map: { $_ => True };
  }
  method gist {
    "valve $.label ($.rate) -> { @.tunnels.join(',') } (score: $.score)"
  }
  method Str {
    "valve $.label ($.rate)";
  }
  method leads-to($dest) {
    %!tunnels{ $dest } or False
  }
}

my regex rate { <[0..9]>+ }
my regex label { <[A..Z]> ** 2 }
my regex line { :s Valve <this=label> has flow rate '=' <rate> ';' tunnel[s]? lead[s]? to valve[s]? <tunnel=label>+ % ', ' }

my %valves;
for $in.lines {
  /<line>/ or die "bad parse: $_";
  $/ = $<line>;
  %valves{ ~$<this> } = Valve.new( label => ~$<this>, rate => +$<rate>, tunnels => $<tunnel>.map(*.Str) );
}

#my $how;
sub d($msg) {
  say $msg;
  #$how ~= "$msg\n";
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
  d "minute $minute: we are at $at, valves open: {@open.elems} : { %open.keys.join(',') }, pressure: $pressure";
  return $pressure if $minute == 30 ;
  if @open.elems == %valves.values.grep({.rate > 0}).elems {
    # stay
    say "staying ($minute)";
    return $pressure + total-pressure(:$at, :%open, :minute($minute + 1));
  }
	if !@instructions {
		my $next = best-destination($at,:%open,:$minute);
		say "new destination is from $at to $next";
    my @route := steps-from(:source($at),:dest($next.label));
	  my @new-instructions = @route.map: { :move($_) };
		@new-instructions.push: (:open($next.label));
		return total-pressure(:$at, :%open, :$minute, :instructions(@new-instructions));
  }
  my $do-it = @instructions.shift;
  if $do-it.key eq 'open' {
    say "OPENING $at";
    return $pressure + total-pressure(:$at, open => %open.clone.push($at => True), :minute($minute + 1), :@instructions);
  }
  if $do-it.key ne 'move' {
    die "don't understand $do-it";
  }
  my $next = $do-it.value;
  return $pressure + total-pressure(:at( $next ), :%open, :minute($minute + 1), :@instructions);
}

sub draw-dot {
  say 'digraph flow {';
  for %valves.values -> $v {
    say "  " ~ $v.label ~ ' -> ' ~ $v.tunnels.join(',');
    say "  " ~ $v.label ~ qq| [label="{$v.label}\\n{$v.rate}"]|;
  }
  say '}';
}
#draw-dot;
#exit;

sub compare($v, Int $v-dist, $w, Int $w-dist, :$minute) {
  #  my $eventual-v = (((30 - $minute) - $v-dist) max 0) * $v.rate;
  #my $eventual-w = (((30 - $minute) - $w-dist) max 0) * $w.rate;
  #say "comparing $v ($eventual-v) to $w ($eventual-w)";
  #return $eventual-v <=> $eventual-w;
  if ($w-dist > $v-dist) {
    return ($v.rate * (1 + $w-dist - $v-dist)) <=> $w.rate;
  }
  return $v.rate <=> ($w.rate * (1 + $v-dist - $w-dist));
}

sub best-destination($source,:%open,:$minute --> Valve) {
  say "finding best dest from $source";
	my @candidates = %valves.values.grep: { .rate > 0 && .label ne $source && !%open{.label} }
  #say "candidates are : " ~ @candidates.map: *.label;
	die "no candidates!" if @candidates == 0;
  #say "source $source, minute $minute, cands {@candidates.map(*.label).join(',')}";
	my $winner = @candidates
  .sort( -> $a, $b {
    compare(
     $a, steps-from(:$source, :dest($a.label)).elems,
     $b, steps-from(:$source, :dest($b.label)).elems,
	   :$minute
    )
	 }).tail;
  $winner;
}

say total-pressure(:at<AA>, :minute<1>);
# 1439 too low
# too high 1530
