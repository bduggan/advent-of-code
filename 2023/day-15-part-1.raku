#!/usr/bin/env raku

sub hash($str) {
  my $cv = 0;
  for $str.trim.comb -> $c {
    my $code = $c.ord;
    die "bad input" if $code > 128;
    $cv += $code;
    $cv *= 17;
    $cv = $cv % 256;
  }
  $cv;
}

die "oops" unless hash('HASH') == 52;

my $in = 'rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7';
# $in = 'input'.IO.slurp.trim;
my $sum = 0;
for $in.split(',') {
  my $x = hash($_);
  say "$_ --> $x";
  $sum += $x;
}
