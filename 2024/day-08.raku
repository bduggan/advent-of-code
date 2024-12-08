#!/usr/bin/env raku

my $in = $*ARGFILES.slurp;

class Grid {
  has @.rows;
  has @.antinodes;
  method at(\r,\c) {
    @.rows[r][c] // ''
  }
  method set-antinode(@c, $f) {
    return unless 0 <= @c[0] < @.rows.elems;
    return unless 0 <= @c[1] < @.rows[0].elems;
    say "setting antinode for $f at { @c.raku }";
    @.antinodes[ @c[0] ] ||= [];
    @.antinodes[ @c[0] ][ @c[1] ] = $f;
  }
  method count-antinodes {
    my $i = 0;
    for @.antinodes.kv -> $r, $row {
      for $row.kv -> $c, $cell {
        $i++ if ( $cell.defined || @.rows[$r][$c] ne '.' );
        #say "antinode at $r, $c";
        #$i++;
      }
    }
    return $i;
  }
}

my \og = Grid.new: rows => $in.lines.map: (*.comb.list);

my @freqs = unique og.rows.flatmap: *.unique;
@freqs .= grep: * ne '.';
say @freqs;

for @freqs -> $f {
  my @all;
  for og.rows.kv -> $r, $v {
    for $v.kv -> $c, $cell {
      push @all, @( $r, $c ) if $cell eq $f;
    }
  }
  say $f ~ " are at: " ~ @all.raku;
  my @others;
  for @all.combinations(2) -> $c {
    for 1..100 {
      og.set-antinode($c[1] >>->> ( ($c[0] >>->> $c[1]) >>*>> $_) , $f);
      og.set-antinode($c[0] >>->> ( ($c[1] >>->> $c[0]) >>*>> $_), $f);
      og.set-antinode($c[0] >>+>> ( ($c[1] >>->> $c[0]) >>*>> $_), $f);
      og.set-antinode($c[1] >>+>> ( ($c[0] >>->> $c[1]) >>*>> $_) , $f);
    }
  }
}

say og.count-antinodes;

