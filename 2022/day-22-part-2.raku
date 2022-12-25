#!/usr/bin/env raku

use Repl::Tools;
unit sub MAIN(Bool :$real, Int :$*max-moves, Bool :$*mark = True, Bool :$debug = False);

sub debug($str) {
  say $str if $debug;
}

# handy methods for making edges
sub infix:<to>(@x,@y) {
  die "invalid range {@x} to {@y}" unless @x[1] == @y[1] || @x[0] == @y[0];
  (@x[0] ... @y[0]) X, (@x[1] ... @y[1])
}

my \E = $real ?? 50 !! 4; # edge length

multi edge($col-start, $col-end, :$row!) {
  die "bad range ($col-end - $col-start)" unless abs($col-end - $col-start) == E - 1;
  ($row, $col-start) to ($row, $col-end)
}
multi edge($row-start, $row-end, :$col!) {
  die "bad range ($row-end - $row-start)" unless abs($row-end - $row-start) == E - 1;
  ($row-start, $col) to ($row-end, $col)
}

# some global types
my @dirnames = <right up left down>;
subset Dirnames of Str where @dirnames.any;

# class for a position + a direction
class Turtle does Positional {
  has Dirnames $.facing;
  has Int @.pos[2] handles <AT-POS Str gist>;

  my @dir-symbols = <→ ↑ ← ↓>;
  my %dir-vectors = up => (-1,0), down => (1,0), left => (0,-1), right => (0,1);

  method facing-index  { %( @dirnames.kv.reverse ){ $!facing } }
  method facing-symbol { @dir-symbols[ self.facing-index ]     }
  method facing-vector { %dir-vectors{ $.facing }              }
  method left {
    Turtle.new: :@.pos, facing => @dirnames[( self.facing-index + 1 ) % 4 ];
  }
  method right {
    Turtle.new: :@.pos, facing => @dirnames[( self.facing-index - 1 ) % 4 ];
  }
  method turned-around {
    Turtle.new: :@.pos, facing => @dirnames[(self.facing-index + 2) % 4];
  }
}

# turn a hash of positions into a hash whose values also have a direction
sub infix:<facing>(%h, $facing) {
  %( %h.keys Z=> %h.values.map: { Turtle.new(:pos(@$_), :$facing) } )
}

# Read input first
my $in = slurp $real ?? 'day-22.input' !! 'day-22.example';
my ($board,$moves) = $in.split(/\n\n/);
my @moves = $moves.trim.comb: / <[0..9]>+ | R | L /;
my @grid = $board.lines.map: *.comb.list.Array;
my %next-pos = up => {}, left => {}, down => {}, right => {};

# edge numbers start at the top edge, going clockwise
# see day-22.docs for numbers of each of the edges
if $real {
  my @e1  = edge(:row(0)       , E, 2 * E - 1);
  my @e2  = edge(:row(0)       , 2*E, 3*E - 1);
  my @e9  = edge(:row(4*E - 1) , 0, E - 1);
  my @e3  = edge(:col(3*E - 1) , 0, E-1);
  my @e6  = edge(:col(2*E - 1) , 3*E - 1, 2*E);
  my @e4  = edge(:row(E - 1)   , 2*E, 3*E - 1);
  my @e5  = edge(:col(2*E - 1) , E, 2*E - 1);
  my @e7  = edge(:row(3*E - 1) , E, 2*E -1);
  my @e8  = edge(:col(E - 1)   , 3*E, 4*E - 1);
  my @e10 = edge(:col(0)       , 3 * E, 4 * E - 1);
  my @e11 = edge(:col(0)       , 2*E, 3*E - 1);
  my @e12 = edge(:row(2*E)     , E - 1, 0);
  my @e13 = edge(:col(E)       , 2*E - 1, E);
  my @e14 = edge(:col(E)       , E - 1, 0);

  # this means: going up from edge 1 leads to edge 10, facing right
  %next-pos<up>.push:    %(@e1 Z=> @e10) facing 'right';

  %next-pos<left>.push:  %(@e10 Z=> @e1) facing 'down';
  %next-pos<up>.push:    %(@e2 Z=> @e9) facing 'up';
  %next-pos<down>.push:  %(@e9 Z=> @e2) facing 'down';
  %next-pos<right>.push: %( @e3 Z=> @e6 ) facing 'left';
  %next-pos<right>.push: %( @e6 Z=> @e3 ) facing 'left';
  %next-pos<down>.push:  %( @e4 Z=> @e5 ) facing 'left';
  %next-pos<right>.push: %( @e5 Z=> @e4 ) facing 'up';
  %next-pos<down>.push:  %( @e7 Z=> @e8 ) facing 'left';
  %next-pos<right>.push: %( @e8 Z=> @e7 ) facing 'up';
  %next-pos<up>.push:    %( @e12 Z=> @e13 ) facing 'right';
  %next-pos<left>.push:  %( @e13 Z=> @e12 ) facing 'down';
  %next-pos<left>.push:  %( @e11 Z=> @e14 ) facing 'right';
  %next-pos<left>.push:  %( @e14 Z=> @e11 ) facing 'right';
} else {
  my @e1  = edge(:row(0),       2*E,     3*E - 1);
  my @e2  = edge(:col(3*E - 1), 0,       E - 1);
  my @e3  = edge(:col(3*E - 1), E,       2*E - 1);
  my @e4  = edge(:row(2*E),     4*E - 1, 3*E );
  my @e5  = edge(:col(4*E - 1), 3*E - 1, 2*E );
  my @e6  = edge(:row(3*E - 1), 3*E,     4*E - 1);
  my @e7  = edge(:row(3*E - 1), 2*E,     3*E - 1);
  my @e8  = edge(:col(2*E),     2*E,     3*E - 1);
  my @e9  = edge(:row(2*E - 1), 2*E - 1, E);
  my @e10 = edge(:row(2*E - 1), E - 1,   0);
  my @e11 = edge(:col(0),       2*E - 1, E );
  my @e12 = edge(:row(E),       E - 1,   0);
  my @e13 = edge(:row(E),       E,       2*E - 1);
  my @e14 = edge(:col(2*E),     0,       E - 1);
  %next-pos<up>.push:    %( @e13 Z=> @e14 ) facing 'right';
  %next-pos<left>.push:  %( @e14 Z=> @e13 ) facing 'down';
  %next-pos<up>.push:    %( @e12 Z=> @e1  ) facing 'down';
  %next-pos<up>.push:    %( @e1  Z=> @e12 ) facing 'down';
  %next-pos<down>.push:  %( @e7  Z=> @e10 ) facing 'up';
  %next-pos<down>.push:  %( @e10 Z=> @e7  ) facing 'up';
  %next-pos<left>.push:  %( @e8  Z=> @e9  ) facing 'up';
  %next-pos<down>.push:  %( @e9  Z=> @e8  ) facing 'right';
  %next-pos<right>.push: %( @e2  Z=> @e5  ) facing 'left';
  %next-pos<right>.push: %( @e5  Z=> @e2  ) facing 'left';
  %next-pos<right>.push: %( @e3  Z=> @e4  ) facing 'down';
  %next-pos<up>.push:    %( @e4  Z=> @e3  ) facing 'left';
  %next-pos<down>.push:  %( @e6  Z=> @e11 ) facing 'right';
  %next-pos<left>.push:  %( @e11 Z=> @e6  ) facing 'up';
}


sub draw {
  my \max-col = max $board.lines».chars;
  put '     ' ~ (0..9).join x (max-col div 10 + 1);
  for @grid.kv -> \r, @row {
    put r.fmt('%4d ') ~ @row.join;
  }
}

sub next-pos($t, Bool :$verify = True) {
  with %next-pos{ $t.facing }{ ~$t.pos } -> Turtle $p {
    debug "hit an edge at {$t.facing} {~$t.pos}";
    if $verify {
      my $test = next-pos($p.turned-around, :!verify);
      if $test[0] != $t[0] || $test[1] != $t[1] {
        note "invalid edge";
        repl;
      }
    }
    return $p;
  }
  debug "no edge";
  my @next = $t.pos »+» $t.facing-vector;
  Turtle.new(:pos(@next), :facing($t.facing));
}

sub g(\pos) {
  @grid[pos[0];pos[1]]
}

sub mark-move($t) {
  die "not defined" without g($t.pos);
  return unless $*mark;
  @grid[$t.pos[0];$t.pos[1]] = $t.facing-symbol;
}

sub try-move($t) {
 my $new-t = next-pos($t);
 return $t if g($new-t.pos) eq '#';
 mark-move($new-t);
 return $new-t;
}

sub move($n, Turtle $t is rw) {
  state $moves-made = 0;
  $moves-made++;
  say "move $moves-made: going $n " ~ $t.facing;
  $t = try-move($t) for 0 ..^ $n; 
  mark-move($t);
  last if $*max-moves && $moves-made >= $*max-moves;
  $t;
}

my $t = Turtle.new: :pos([0, @grid[0].first(:k, * ne ' ')]), :facing<right>;
for @moves -> $move {
  debug "instruction: " ~ $move.raku;
  given $move {
    when 'L' { $t = $t.left }
    when 'R' { $t = $t.right }
    when /<[0..9]>+/ { $t = move($move, $t) }
    default { die "error $move" }
  }
}

draw;

my %facing-score = <right up left down> Z=> <0 3 2 1>;
my ($final-row, $final-col) = $t.pos »+» [1,1];
my $pw = 1000 * $final-row + 4 * $final-col + %facing-score{$t.facing};
say "password is: 1000 * $final-row + 4 * $final-col + { %facing-score{$t.facing} } == $pw";
