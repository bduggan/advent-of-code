#!/usr/bin/env raku

my @grid;

for 'input/day-05.input'.IO.lines {
  my ($a,$b,$c,$d) = .comb(/\d+/);
  if $a == $c {
    @grid[$_][$a]++ for $b ... $d
  } elsif $b == $d {
    @grid[$b][$_]++ for $a ... $c
  } else {
    @grid[$a][$b]++;
    @grid[$c][$d]++;
  }
}

for @grid -> $row {
  for $row<> {
    print $_ // '.';
  }
  print "\n";
}

put '--';
put [+] @grid.map: {
        [+] .map: { ( ($_ // 0) > 1).Int }
};

# > 359
# > 372


