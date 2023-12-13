unit sub MAIN($file = 'input');

sub lines-of-reflection(@lines, :$smudge) {
  my @h;
  LINE:
  for 0^...^(@lines[0].elems) -> \c {
    for @lines.kv -> \r, $l-orig {
      my $l = [ @$l-orig ];
      if $smudge && (r == $smudge<row>) {
        $l[$smudge<col>] = ($l[$smudge<col>] eq '#' ?? '.' !! '#');
      }
      next LINE unless all( $l[c^...0] Zeq $l[c..*] );
    }
    @h.push: c;
  }
  @h;
}

sub find-line-smudged(@lines, @l) {
  my @new-lines;
  for @lines.kv -> $row,$l {
    for $l.keys -> $col {
      my @k = lines-of-reflection(@lines, smudge => %( :$row, :$col ));
      next unless @k;
      next if @l && @k.join(',') eq @l.join(',');
      @new-lines.append: @k;
    }
  }
  my @n = @new-lines.unique;
  my @diff = @n.Set (-) @l.Set;
  return @diff.head.key
}

my $total = 0;
my @all = $file.IO.slurp.split(/\n\n/);
for @all.kv -> $i,$p {
  say "doing $i of {@all.elems}";
  my @lines = $p.lines.map: *.comb.Array;
  my @vert-l = lines-of-reflection(@lines);
  my @horz-l = lines-of-reflection([Z] @lines);
  my $new-line-vert = find-line-smudged(@lines, @vert-l);
  my $new-line-horz = find-line-smudged(([Z] @lines), @horz-l);
  $total += ($new-line-vert || 0) + 100 * ($new-line-horz || 0);
}

say $total;

