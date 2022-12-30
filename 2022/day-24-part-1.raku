#!/usr/bin/env raku

# define "%1" as module arithmetic (like %) but from 1..N instead of 0..N-1
sub infix:<%1>($x,$m) is looser(&infix:<+>) {
  1 + ($x - 1) % $m
}

# compare equality of arrays, because eqv distinguishes shaped arrays
sub infix:<@==>($x,$y) {
  $x[0] == $y[0] && $x[1] == $y[1]
}


subset Dirs of Str where ('>','<','v','^').any;
class Blizzard does Positional {
  has Int @.pos[2] handles <AT-POS>;
  has Dirs $.dir;
  method position-at(:$minute) {
    given $.dir {
      when '>' { (@.pos[0], @.pos[1] + $minute %1 $*max-c) }
      when '<' { (@.pos[0], @.pos[1] - $minute %1 $*max-c) }
      when '^' { (@.pos[0] - $minute %1 $*max-r, @.pos[1]) }
      when 'v' { (@.pos[0] + $minute %1 $*max-r, @.pos[1]) }
    }
  }
}

class Traveler does Positional {
  has Int @.pos[2] handles <AT-POS>;
  has $.minute = 0;

  method Str {
    "[traveler after minute $.minute at {@.pos.join(',')}]"
  }
  method arrived {
    @.pos @== @*final-pos
  }
  method moves {
    my $minute = $!minute + 1;
    my @moves;
    for (0,0), (-1,0), (1,0), (0,-1), (0,1) -> @dir {
      with (@.pos Z+ @dir) -> @pos {
        next unless self.arrived ||
                    (   $*min-r ≤ @pos[0] ≤ $*max-r
                     && $*min-c ≤ @pos[1] ≤ $*max-c );
        @moves.push: Traveler.new: :$minute, :@pos;
      }
    }
    die "no moves" unless @moves;
    @moves;
  }

  method distance-to-exit {
    abs(@.pos[0] - @*final-pos[0]) + abs(@.pos[1] - @*final-pos[1])
  }

}

my @blizzards;
my @grid;
sub setup(:$real) {
  my $in = q:to/IN/;
  #.######
  #>>.<^<#
  #.<..<<#
  #>v.><>#
  #<^v^^>#
  ######.#
  IN
  $in = slurp 'day-24.input' if $real;

  @grid = $in.lines.map: *.comb;
  for @grid.kv -> \r, @row {
    for @row.kv -> \c, $col {
      next unless $col ~~ Dirs;
      @blizzards.push: Blizzard.new: pos => [r,c], dir => $col;
    }
  }
}

sub valid($t) {
  not @blizzards.first({ $t.pos @== .position-at(:minute($t.minute)) }).defined
}

sub MAIN(Bool :$*quiet, :$real, :$until) {
  setup(:$real);
  my Traveler $t = Traveler.new: pos => [0,1];

  my ($*min-r, $*min-c) = (1,1);
  my ($*max-r, $*max-c) = @grid.elems - 2, @grid[0].elems - 2;
  my @*final-pos = ( $*max-r, $*max-c );

  my @frontier = ( $t );
  loop {
    my @next-frontier;
    last if $until && @frontier[0].minute == $until;
    say "nodes at minute { @frontier[0].minute }: " ~ @frontier.elems;
    for @frontier -> Traveler $f {
      for $f.moves -> $t {
        next unless valid($t);
        if $t.arrived {
          say "arrived at the destination after minutes: " ~ $t.minute + 1;
          exit;
        }
        @next-frontier.push: $t;
      }
    }
    @frontier = @next-frontier.unique(with => { $^x.pos eqv $^y.pos })
                              .sort(*.distance-to-exit).head(40);
  }
}

