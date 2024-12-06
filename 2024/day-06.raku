#!/usr/bin/env raku

my $in = 'in/day-6'.IO.slurp;

class Grid {
  has @.rows;
  has $.guard-position;
  has $.guard-direction;
  method find-guard {
    my ($r, $row) = @.rows.first: :kv, { .join.contains('^') };
    my $c = $row.first: :k, * eq '^';
    $!guard-position = [ $r, $c];
    $!guard-direction = 'up';
  }
}

my \g = Grid.new: rows => $in.lines.map: (*.comb.list);
g.find-guard;

