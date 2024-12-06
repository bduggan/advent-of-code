#!/usr/bin/env raku

my $in = $*ARGFILES.slurp;

use Terminal::ANSI::OO 't';

class Grid {
  has @.rows;
  has %.seen;
  has $.pos;
  has $.guard-direction;
  method row { $!pos[0] }
  method col { $!pos[1] }
  method find-guard {
    my ($r, $row) = @.rows.first: :kv, { .join.contains('^') };
    my $c = $row.first: :k, * eq '^';
    $!pos = [ $r, $c];
    $!guard-direction = [-1,0];
    %!seen{ $!pos.raku }++;
  }
  method icon {
    return '^' if $!guard-direction eq [-1,0];
    return 'v' if $!guard-direction eq [1,0];
    return '<' if $!guard-direction eq [0,-1];
    return '>' if $!guard-direction eq [0,1];
  }
  method move-guard {
    $!pos >>+=>> $!guard-direction;
    my $at = @.rows[ $.pos[0] ][ $.pos[1] ];
    if ($at && $at eq '#') {
      $!pos >>-=>> $!guard-direction;
      # turn right
      $!guard-direction = [ $!guard-direction[1], -$!guard-direction[0] ];
      return;
    }
    %!seen{ $!pos.raku }++ unless self.out-of-grid;
  }
  method out-of-grid {
    not (0 <= $!pos[0] < @!rows ) && ( 0 <= $!pos[1] < @!rows[0] )
  }
  method show {
    put t.clear-screen;
    for @!rows.kv -> $r, $row {
      if $!pos[0] == $r {
        say (|$row[0..self.col - 1], self.icon, |$row[( self.col+1 )..*]).join;
      } else {
        say $row.join;
      }
    }
    sleep 1;
  }
}

my \g = Grid.new: rows => $in.lines.map: (*.comb.list);
g.find-guard;

loop {
  #g.show;
  g.move-guard;
  last if g.out-of-grid;
}

say "seen : " ~ g.seen.keys.elems;
