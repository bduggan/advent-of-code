#!/usr/bin/env raku

use Repl::Tools;

my $in = q:to/IN/;
root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32
IN

$in = "day-21.input".IO.slurp;

my %monkeys;
for $in.lines {
  my ($name,$inst) = .split(': ');
  %monkeys{ $name } = $inst;
}

my regex monkey { <[a..z]> ** 4 }
my regex op { '+' | '-' | '*' | '/' }

my %op = '+' => &infix:<+>, '-' => &infix:<->, '*' => &infix:<*>, '/' => &infix:</>;

sub has-value($monkey) {
  repl unless defined( %monkeys{ $monkey } );
  %monkeys{ $monkey } ~~ Numeric
    or val( %monkeys{ $monkey } ) ~~ Numeric
}

sub try-eval($v) {
  say "trying $v";
  $v ~~ /:s <one=monkey> <op> <two=monkey>/ or die "bad expression $v";
  return Nil unless has-value([~$<one>, $<two>].all);
  my $res = %op{ ~$<op> }( %monkeys{~$<one>}, %monkeys{ ~$<two> });
  say "evaluated $v and got $res";
  $res;
}

while !has-value( "root" ) {
  for %monkeys.kv -> $name, $value is rw {
    next if has-value($name);
    $value = $_ with try-eval($value);
  }
}

say %monkeys<root>;
