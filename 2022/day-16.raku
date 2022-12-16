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

class Valve {
  has Str $.label;
  has Int $.rate;
  has Str @.tunnels;
  has Bool %!tunnels;
  method TWEAK {
    %!tunnels = @.tunnels.map: { $_ => True };
  }
  method gist {
    "valve $.label ($.rate) -> { @.tunnels.join(',') }"
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
  d "minute $minute: we are at $at, valves open: { %open.keys.join(',') }, pressure: $pressure";
  return $pressure if $minute == 30 ;
  if !@instructions || @open.elems == %valves.keys.elems {
    # stay
    return $pressure + total-pressure(:$at, :%open, :minute($minute + 1));
  }
  my $do-it = @instructions.shift;
  if $do-it.key eq 'open' {
    return $pressure + total-pressure(:$at, open => %open.clone.push($at => True), :minute($minute + 1), :@instructions);
  }
  if $do-it.key ne 'move' {
    die "don't understand $do-it";
  }
  my $next = $do-it.value;
  return $pressure + total-pressure(:at( $next ), :%open, :minute($minute + 1), :@instructions);
}

# say total-pressure(:at<AA>, open => { }, :minute<15>);

my @non-zero = sort %valves.values.grep(*.rate > 0).map: *.label;
my $max = 0;
my @p = <DD BB JJ HH EE CC>;
for @non-zero.permutations -> @p {
  say "opening in this order: {@p}";
  my @instructions;
  for steps-from(:source<AA>, :dest(@p[0]))<> {
    @instructions.push: (move => ($_));
  }
  for @p.rotor(2 => -1) -> ($from,$to) {
    @instructions.push: (open => ($from));
    for steps-from(:source($from),:dest($to))<> {
      @instructions.push: (move => $_);
    }
  }
  @instructions.push: (open => (@p[*-1]));
  # say "instructions: " ~ @instructions.raku;
  my $p = total-pressure(:at<AA>, :minute<1>, :@instructions);
  $max max= $p;
  say "TOTAL pressure is $p";
}

say "max is $max";
#AA 0;  DD, II, BB
#BB 13; CC, AA
#CC 2;  DD, BB
#DD 20; CC, AA, EE
#EE 3;  FF, DD
#FF 0;  EE, GG
#GG 0;  FF, HH
#HH 22; GG
#II 0;  AA, JJ
#JJ 21; II

