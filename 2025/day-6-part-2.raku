#!/usr/bin/env raku

my @in = 'input-real-6'.IO.lines.map: *.comb;
my @rows = [Z] @in;
my $tot;
loop {
  last unless @rows;
  my @r = @rows.shift.Array;
  my $op = @r.pop;
  if $op ne ' ' {
    my @terms = @r.join;
    while @rows && @rows.head.any ~~ /\d/ {
      @terms.push: @rows.shift;
    }
    my @nums = @terms.map(*.join).map(+*);
    my $str = "[$op] {@nums.join(',')}";
    $tot += $str.EVAL;
  }
}
say $tot;
