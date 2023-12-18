my $in = q:to/IN/;
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
IN

#(O O . O . O . . # #)
#(. . . O O . . . . #)
#(. O . . . # O . . O)
#(. O . # . . . . . O)
#(. # . O . . . . . .)
#(# . # . . O # . # .)
#(. . # . . . O . # #)
#(. . . . O # . O # .)
#(. . . . # . . . . .)
#(. # . O . # O . . .)

$in = 'input.real'.IO.slurp;

my @trans = [Z] $in.lines.map: *.comb.Array;
my @new;
.join.say for @trans;
say '--';
for @trans -> @l {
  my $str = @l.join;
  #say "start $str";
  loop {
    #say 'before ' ~ $str;
    $str ~~ s:g/ '.' 'O'/O./ or last;
    #say 'after '  ~ $str;
  }
  @new.push: $str;
}

.say for @new;

my $load = 0;

for @new {
  say "line $_";
  for .comb.grep(:k, 'O') -> $i {
    say "adding " ~ (.chars - $i);
    $load += ( .chars - $i )
  }
}

say $load;
