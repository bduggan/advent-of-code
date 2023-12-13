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

my $total = 0;
my @all = 'input.real'.IO.slurp.split(/\n\n/);
for @all {
  my @lines = .lines.map: *.comb;
  $total += sum lines-of-reflection(@lines);
  $total += 100 * sum lines-of-reflection([Z] @lines);
}

say $total;

