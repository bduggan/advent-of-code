#!/usr/bin/env raku

my $in = $*ARGFILES.slurp;

use Terminal::ANSI::OO 't';

class Grid {
  has @.rows;
  has @.obstacles;
  has %.seen;
  has %.state;
  has $.pos;
  has $.guard-direction;
  method row { $!pos[0] }
  method col { $!pos[1] }
  method at(\r,\c) {
    return '#' if @.obstacles[r][c];
    @.rows[r][c] // ''
  }
  method set-state {
    %!state{ $!pos.raku ~ $!guard-direction.raku }++;
  }
  method reset-state {
    %!state = %( );
  }
  method seen-state {
    %!state{ $!pos.raku ~ $!guard-direction.raku }:exists;
  }
  method find-guard {
    my ($r, $row) = @.rows.first: :kv, { .join.contains('^') };
    my $c = $row.first: :k, * eq '^';
    $!pos = [ $r, $c];
    $!guard-direction = [-1,0];
    %!seen{ $!pos.raku }++;
    self.set-state;
  }
  method icon {
    return '^' if $!guard-direction eq [-1,0];
    return 'v' if $!guard-direction eq [1,0];
    return '<' if $!guard-direction eq [0,-1];
    return '>' if $!guard-direction eq [0,1];
  }
  method move-guard {
    $!pos >>+=>> $!guard-direction;
    if ( self.at( $.pos[0], $.pos[1] ) eq '#' ) {
      $!pos >>-=>> $!guard-direction;
      # turn right
      $!guard-direction = [ $!guard-direction[1], -$!guard-direction[0] ];
      return;
    }
    %!seen{ $!pos.raku }++ unless self.out-of-grid;
  }
  method row-count { +@!rows }
  method col-count { +@!rows[0] }
  method out-of-grid {
    not (0 <= $!pos[0] < self.row-count ) && ( 0 <= $!pos[1] < self.col-count )
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
  method go(Bool :$debug) {
    self.reset-state;
    self.find-guard;
    loop {
      self.show if $debug;
      self.move-guard;
      if self.seen-state {
        return "loop";
      }
      self.set-state;
      last if self.out-of-grid;
    }
    "exit";
  }
  method add-obstacle(\r,\c) {
    @!obstacles = ();
    @!obstacles[r][c] = 1;
  }
}

my \og = Grid.new: rows => $in.lines.map: (*.comb.list);
og.go;
say "part one : " ~ og.seen.keys.elems;

my atomicint $count = 0;
my @p;
for 0..^og.row-count -> \r {
  @p.push: start {
    my \g = Grid.new: rows => $in.lines.map: (*.comb.list);
    for 0..^og.col-count -> \c {
      next unless g.at(r,c) eq '.';
      g.add-obstacle(r,c);
      next unless g.go eq 'loop';
      say "loop { r } { c } ";
      $count⚛++;
    }
  }
}
await @p;
say "loop positions: $count";

