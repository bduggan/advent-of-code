#!/usr/bin/env raku

my $in = 'input'.IO.slurp;

my @found;
my %gears;

for $in.lines.kv -> $row,$line {
  for $line.match( /\d+/, :g)  {
    my @gears := nearby-gears($row, .from, .to);
    @found.push: %( num => +$_, gears => @gears.map(*.raku) );
  }
}

%gears{ .<gears> }.push: .<num> for @found;

say sum %gears.grep({.value.elems == 2}).map: { [*] .value.List }

sub has-gear($row,$col) {
  0 < $row < $in.lines
    and 0 < $col < $in.lines[0].chars
    and $in.lines[$row].comb[$col] eq '*';
}

sub nearby-gears($row,$from,$to) {
  @ = ( |( ($row - 1, $row, $row + 1) X, ( $from - 1, $to ) ),
        |( ($row - 1, $row + 1) X, ($from .. $to - 1) )
  ).grep: -> ($row,$col) { has-gear($row, $col) }
}
