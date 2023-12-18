#!/usr/bin/env raku

unit sub MAIN($file = 'input');

my $in = $file.IO.slurp;
my @grid = $in.lines.map: *.comb.Array;
my \cols = @grid[0].elems;
my \rows = @grid.elems;

class Path {
  has @.pos;
  has @.prev;
  has @.moves;
  has %.seen;
  method row { @.pos[0] }
  method col { @.pos[1] }
  method heat-loss { sum @.prev // 0; }
  method moved($dir) { @.moves > 2 && @.moves.tail(3).unique.join eq $dir; }
  method last-move { @.moves.tail // 'none'; }
  method move-right {
    return Empty if self.col >= cols - 1 || self.moved('right');
    return Empty if self.last-move eq 'left';
    self.move(0,1,'right');
  }
  method move-left {
    return Empty if self.col <= 0 || self.moved('left');
    return Empty if self.last-move eq 'right';
    self.move(0,-1,'left');
  }
  method move-up {
    return Empty if self.row <= 0 || self.moved('up');
    return Empty if self.last-move eq 'down';
    self.move(-1,0,'up');
  }
  method move-down {
    return Empty if self.row >= rows - 1 || self.moved('down');
    return Empty if self.last-move eq 'up';
    self.move(1,0,'down')
  }
  method move($d-row,$d-col,$dir) {
    return Empty if %.seen{ (@.pos[0] + $d-row ) ~ ',' ~ (@.pos[1] + $d-col) }++;
    @.moves.push: $dir;
    @.pos »+=» ( $d-row, $d-col );
    @.prev.unshift: @grid[ self.row ][ self.col ];
    self;
  }
  method clone {
    return Path.new( :@.pos, :@.prev, :@.moves );
  }
  method posstr {
    @.pos.join(',')
  }
  method distance-to-end {
    (rows - 1 - self.row) + (cols - 1 - self.col);
  }
}
say @grid.map(*.join).join("\n");
#my $p = Path.new(pos => [0,0]);
#$p.move-right; say $p;
#$p.move-right; say $p;
#$p.move-right; say $p;
#$p.move-down; say $p;
#$p.move-right; say $p;
#exit;

use Repl::Tools;
my @edge = ( Path.new(pos => [0,0]) );
#my $p = @edge[0];
#repl;
my @found;
my %min-heatloss;
loop {
  my @new-edge = @edge.flatmap: -> $p {
      |($p.clone.move-left, $p.clone.move-right, $p.clone.move-up, $p.clone.move-down);
  }
  @edge = @new-edge.sort(*.heat-loss);
  for @edge {
    %min-heatloss{ .posstr } ||= .heat-loss;
    %min-heatloss{ .posstr } min= .heat-loss;
  }
  @edge = @edge.grep({ .heat-loss <= %min-heatloss{ .posstr } + 1  });
  say "nodes in edge: " ~ @edge.elems;
  say "min distance to end: " ~ @edge.map(*.distance-to-end).min;
  @edge = @edge.sort({ .distance-to-end }).head(500);
  for @edge {
    if (.row == rows - 1 and .col == cols - 1) {
      @found.push: .heat-loss;
      note "found : " ~ @found.unique ~ "min: " ~ @found.unique.min;
    }
  }
  last if @edge == 0;
}
say @found.unique.min;
# 1114 too high
