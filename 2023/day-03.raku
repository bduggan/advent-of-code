#!/usr/bin/env raku

my $in = q:to/IN/;
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
IN

say $in;

my regex part { \d+ }

my $sum;
my @found;

for $in.lines.kv -> $row,$line {
  for $line.match( /<part>/, :g)».<part> -> $num {
    next unless is-part($row,$num.from,$num.to);
    $sum += $num;
    @found.push: +$num;
  }
}

exit note "no parts" without $sum;

sub has-symbol($row,$col) {
  return False if $row < 0 || $row ≥ $in.lines;
  return False if $col < 0 || $col ≥ $in.lines[0].chars;
  my $c = $in.lines[$row].substr($col,1);
  return False if $c eq any( '.', |(0..9));
  return True;
}

sub is-part($row,$from,$to) {
  return True if
  ( |( ($row - 1, $row, $row + 1) X, ( $from - 1, $to ) ),
    |( ($row - 1, $row + 1) X, ($from .. $to - 1) )
  ).grep: -> ($row,$col) { has-symbol($row, $col) }
  return False;
}
