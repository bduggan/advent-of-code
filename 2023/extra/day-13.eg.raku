my $in = q:to/IN/;
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.
IN
# between 5 and 6

sub lines-of-reflection(@lines) {
  my @h;
	LINE:
	for 0^..^(@lines[0].elems) -> \n {
		for @lines {
			next LINE unless all( .[n^...0] Zeq .[n..*] );
		}
		@h.push: n;
	}
  @h;
}

my @lines = $in.lines.map: *.comb;
say lines-of-reflection(@lines).raku;

my $in2 = q:to/IN/;
#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
IN
@lines = $in2.lines;
@lines = [Z] @lines;

say lines-of-reflection(@lines).raku;
