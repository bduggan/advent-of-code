#!/usr/bin/env raku

use Repl::Tools;
use Terminal::ANSI::OO 't';

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
  has %!cache;
  method position-at(:$minute) {
    %!cache{$minute} //= do
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
  method leaving {
    @.pos @== @*initial-pos
  }

  method moves {
    # all possible moves from this one.
    # wait, or move in any direction, checking edges
    my $minute = $!minute + 1;
    my @moves;
    for (0,0), (-1,0), (1,0), (0,-1), (0,1) -> @dir {
      with (@.pos Z+ @dir) -> @pos {
        # say "trying {@pos}";
        next unless self.arrived 
           || ( $*min-r ≤ @pos[0] ≤ $*max-r && $*min-c ≤ @pos[1] ≤ $*max-c )
           || ( self.leaving && @dir[0] == 0 && @dir[1] == 0 );
        @moves.push: Traveler.new: :$minute, :@pos;
      }
    }
    unless @moves {
      say "no moves";
      repl;
    }
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

  if $real {
    $in = slurp 'day-24.input';
  }

  @grid = $in.lines.map: *.comb;
  for @grid.kv -> \r, @row {
    for @row.kv -> \c, $col {
      if $col ~~ Dirs {
        my $b = Blizzard.new: pos => [r,c], dir => $col;
        @blizzards.push: $b;
      }
    }
  }
}

sub valid($t) {
  not @blizzards.first({ $t.pos @== .position-at(:minute($t.minute)) }).defined
}

sub draw-expedition($t) {
  return if $*quiet;
  say "drawing at minute {$t.minute} T:{$t.pos.join(',')}";
  for @grid.kv -> \r, @row {
    for @row.kv -> \c, $col {
      my @snow = @blizzards.grep: { .position-at(:minute($t.minute)) @== [r,c] }
      if [r,c] @== $t.pos {
        print t.bold ~ "T" ~ t.text-reset;
        if @snow > 0 {
          note "impossible.  caught in blizzard";
          repl;
        }
      } elsif @snow.elems == 1 {
        print @snow[0].dir;
      } elsif @snow.elems > 1 {
        print @snow.elems % 10;
      } else {
        print $col eq '#' ?? '#' !! '.';
      }
    }
    print "\n";
  }
  print "\n";
}

sub travel-to($t, $dst-r, $dst-c) {
  my @*final-pos = $dst-r, $dst-c;

  # breadth first search
  my @frontier = ( $t );

  draw-expedition($t);
  loop {
    my @next-frontier;
    say "nodes in frontier: at minute { @frontier[0].minute }: " ~ @frontier.elems;
    for @frontier -> Traveler $f {
      for $f.moves -> $t {
        next unless valid($t);
        draw-expedition($t);
        if $t.arrived {
          say "arrived at the destination after minutes: " ~ $t.minute + 1;
          return $t;
        }
        @next-frontier.push: $t;
      }
    }
    if @next-frontier == 0 {
      say "no moves!";
      repl;
    }
    @frontier = @next-frontier.unique(with => -> $x,$y { $x.pos eqv $y.pos });

    my $min = (min @frontier.map: *.distance-to-exit);
    my $max = (max @frontier.map: *.distance-to-exit);
    if $*prune && @frontier > 300 {
      my $cutoff = $min + .90 * ($max - $min);
      say "pruning to distance < $cutoff";
      my @pruned = @frontier.grep: { .distance-to-exit < $cutoff }
      @frontier = @pruned if @pruned > 0;
    }
  }
}

sub MAIN(Bool :$*quiet, :$real) {
  setup(:$real);
  my Traveler $t = Traveler.new: pos => [0,1];

  my ($*min-r, $*min-c) = (1,1);
  my @*initial-pos = $*min-r, $*min-c;

  my $*max-r = @grid.elems - 2;
  my $*max-c = @grid[0].elems - 2;

  my $*prune = True;
  $t = travel-to($t, @grid.elems - 2, @grid[0].elems - 2 );
  $t = Traveler.new(minute => $t.minute + 1, pos => [ $t.pos[0] + 1, $t.pos[1] ]);
  @*initial-pos = $t.pos;
  $t = travel-to($t, 1, 1);
  $t = Traveler.new(minute => $t.minute + 1, pos => [ $t.pos[0] - 1, $t.pos[1] ]);
  @*initial-pos = $t.pos;
  $t = travel-to($t, @grid.elems - 2, @grid[0].elems - 2 );
  say 'done!';
}
