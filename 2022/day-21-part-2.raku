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

# $in = "day-21.input".IO.slurp;

my %monkeys;
for $in.lines {
  my ($name,$inst) = .split(': ');
  %monkeys{ $name } = $inst;
}

grammar Monkey {
  rule TOP { <one=monkey> <op> <two=monkey> }
  token monkey { <[a..z]> ** 4 }
  token op { '+' | '-' | '*' | '/' }
}

my %op = '+' => &infix:<+>, '-' => &infix:<->, '*' => &infix:<*>, '/' => &infix:</>;

sub has-value($monkey, :%in = %monkeys) {
  return False if %in{$monkey} eq 'UNKNOWN';
  repl unless defined( %in{ $monkey } );
  %in{ $monkey } ~~ Numeric
    or val( %in{ $monkey } ) ~~ Numeric
}

sub try-eval($v, :%in = %monkeys) {
  return Nil if $v eq <CHECK UNKNOWN>.any;
  Monkey.parse($v) or die "bad expression $v";
  return Nil unless has-value([~$<one>, $<two>].all, :%in);
  my $res = %op{ ~$<op> }( %in{~$<one>}, %in{ ~$<two> });
  $res;
}

%monkeys<humn> = 'UNKNOWN';
%monkeys<root> = 'CHECK';

#root: pppw + sjmn
my @top = <pppw sjmn>;
while !has-value(@top.any) {
  for %monkeys.kv -> $name, $value is rw {
    next if $name eq 'humn';
    next if has-value($name);
    $value = $_ with try-eval($value);
  }
}

my $found = @top.grep: { has-value($_) };
say "found $found";
my $other = @top.first: * ne $found;
my %inv = $other => %monkeys{ $found };

sub inverses($name, $eqn) {
  say "inverting $name = $eqn";
  Monkey.parse($eqn);
  my ($one,$two,$op) = ($<one>, $<two>, $<op>).map: ~*;
  my %inv = <+ - * /> Z=> <- + / *>;
  my $inv-op = %inv{ $op };
  # $name == $one $op $two
  # for +, *
  #   $one = $name inv-op $two
  #   $two = $name inv-op $one
  # for -, /
  #    $one = $two inv-op $name
  #    $two = $one op $name
  # x = y + z | x = y * z | x = y - z  | x = y /z
  # y = z - x | y = z / x | y = z + x  | y = x * z
  # z = y - x | z = y / x | z = y - x  | z = y / x
  given $op {
    when <+ *>.any {
      return ( "$one: $name $inv-op $two", "$two: $name $inv-op $one" );
    }
    when <- />.any {
      return ( "$one: $two $inv-op $name", "$two: $one $op $name" );
    }
  }
}

for %monkeys.kv -> $name, $value {
  next if $name eq <root humn>.any;
  if has-value($name) {
    %inv{ $name } = %monkeys{ $name };
    next;
  }
  say "$name: $value";
  for inverses($name,$value) {
    say "adding new inverted eqn: $_";
    my ($name, $eqn) = .split(': ');
    next if %inv{$name} && has-value($name, in => %inv);
    die "overlap with { %inv{$name} }" if %inv{ $name };
    %inv{ $name } = $eqn;
  }
}

say "ready to solve inverses!";

my $filled = 0;
while !has-value('humn', in => %inv) {
   my $now-filled = (%inv.keys.grep: { has-value($_, in => %inv) }).elems;
   if $filled && $now-filled == $filled {
     say "stopped filling at $filled";
     for %inv.kv -> $name, $value { say "$name : $value"; }
     say "---failed--";
     repl;
     exit;
   }
   $filled = $now-filled;
   last if ++$ > 10;
   for %inv.kv -> $name, $value is rw {
     next if has-value($name, in => %inv);
     $value = $_ with try-eval($value, in => %inv);
   }
}
say "--success--";
say %inv<humn>;

