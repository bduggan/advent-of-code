#!/usr/bin/env raku

my @in = 'input-6'.IO.lines.map: *.words;
my @probs = [Z] @in;
my $tot;
for @probs -> @p is copy {
  my $op = @p.pop;
  $tot += "[$op] {@p.join(',')}".EVAL;
}
say $tot;
