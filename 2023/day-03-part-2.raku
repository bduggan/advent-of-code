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

# say $in;
$in = 'input'.IO.slurp;

my regex part { \d+ }

my @found;

for $in.lines.kv -> $row,$line {
  say "row $row";
  for $line.match( /<part>/, :g)».<part> -> $num {
    # next unless $num eq '617';
    # say "checking $num";
    my @gears := nearby-gears($row,$num.from,$num.to);
    next unless @gears > 0;
    # say "$num is next to gears: { @gears.raku }";
    @found.push: %( num => +$num, gears => @gears.map(*.join(',')) );
  }
}

my %gears;
for @found -> $f {
  for $f<gears> -> $g {
    %gears{ $g }.push: $f<num>;
  }
}

my $total;
for %gears {
  my @parts := .value;
  next unless @parts.elems == 2;
  # say "nearby parts: " ~ @parts;
  $total += [*] @parts;
}
say "total $total";

sub has-gear($row,$col) {
  return False if $row < 0 || $row ≥ $in.lines;
  return False if $col < 0 || $col ≥ $in.lines[0].chars;
  my $c = $in.lines[$row].substr($col,1);
  return False if $c eq any( '.', |(0..9));
  return $c eq '*';
}

sub nearby-gears($row,$from,$to) {
  my @gears =
    ( |( ($row - 1, $row, $row + 1) X, ( $from - 1, $to ) ),
      |( ($row - 1, $row + 1) X, ($from .. $to - 1) )
    ).grep: -> ($row,$col) { has-gear($row, $col) }
  return @gears;
}
