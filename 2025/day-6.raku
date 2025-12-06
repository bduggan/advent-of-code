#!/usr/bin/env raku

my @in = 'input-real-6'.IO.lines.map: *.words;
my @probs = [Z] @in;
my $tot;
for @probs -> @p is copy {
  my $op = @p.pop;
  my $str = "[$op] {@p.join(',')}";
  $tot += $str.EVAL;
}
say $tot;
