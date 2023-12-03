#!/usr/bin/env raku

my $in = 'input'.IO.slurp;

my regex part { \d+ }

say sum $in.lines.kv.map: -> $row,$line {
  |$line.match( /<part>/, :g)».<part>.grep: -> $num {
    is-part($row,$num.from,$num.to);
  }
}

sub has-symbol($row,$col) {
  0 < $row < $in.lines
    and 0 < $col < $in.lines[0].chars
    and $in.lines[$row].comb[$col] ne any( '.', |(0..9));
}

sub is-part($row,$from,$to) {
  ( |( ($row - 1, $row, $row + 1) X, ( $from - 1, $to ) ),
    |( ($row - 1, $row + 1) X, ($from .. $to - 1) )
  ).first: { has-symbol($^rc[0], $rc[1]) }
}
