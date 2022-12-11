#!/usr/bin/env raku

my $*product;

my $in = 'day-11.input-sample'.IO.slurp;

class Tester {
  has Int $.divisor;
  has Int $.true;
  has Int $.false;
  method test(Int $n)  {
    $n %% $.divisor ?? $.true !! $.false;
  }
}

class Operator {
  has $.arg1; # number or 'old';
  has $.arg2: # number or 'old';
  has $.operator; # '+ or '*'
  method eval($old) {
    my &op-sub = $.operator eq '+' ?? &infix:<+> !! &infix:<*>;
    op-sub(
      $.arg1 eq 'old' ?? $old !! $.arg1,
      $.arg2 eq 'old' ?? $old !! $.arg2
    )
  }
}

class Monkey {
  has Int $.number;
  has UInt @.items;
  has $.operation;
  has Operator $.operator;
  has Tester $.tester;
  has $.inspected-count = 0;

  method inspect-and-throw(@other-monkeys) {
    while @!items.shift -> $item  {
      my $new-level = $.operator.eval($item);
      my $next-monkey = $.tester.test($new-level);
      @other-monkeys[ $next-monkey ].items.push: $new-level % $*product;
      $!inspected-count++;
    }
  }
}

use Grammar::PrettyErrors;
grammar Monkey::Grammar does Grammar::PrettyErrors {
  token ws { \h* }
  token number { <[0..9]>+ }
  token op { '+' | '*' }
  rule TOP { <monkey>+ %% "\n"+ }
  rule monkey { "Monkey" <number> ":" \n <items> <operation> <test> }
  rule items { "Starting items: " <number>+ % "," \n }
  rule operation { "Operation: " "new =" <expr> <op> <expr> \n }
  token expr { <number> | "old" }

  rule test {
    "Test: divisible by" <divisor=number> \n
        "If true: throw to monkey" <true=number> \n
        "If false: throw to monkey" <false=number> \n
  }
}

class Monkey::Actions {
  method TOP($/) { $/.make: $<monkey>.map: *.made  }
   method monkey($/) {
    $/.make:
       Monkey.new:
          number => +$<number>,
          items => $<items>.made,
          operator => $<operation>.made,
          tester => $<test>.made;
  }
 method items($/) {
    $/.make: $<number>.map: +*
 }
 method operation($/) {
    $/.make: Operator.new:
      arg1 => ~$<expr>[0],
      arg2 => ~$<expr>[1],
      operator => ~$<op>
 }
 method test($/) {
    $/.make: Tester.new(divisor => +$<divisor>, true => +$<true>, false => +$<false>)
 }
}

my $actions = Monkey::Actions.new;
my $match = Monkey::Grammar.parse($in, :$actions);
my @monkeys = $match.made;

$*product = [*] @monkeys.map: *.tester.divisor;

for 1..10_000 -> $round {
  for @monkeys -> $monkey {
    $monkey.inspect-and-throw(@monkeys);
  }
}

for @monkeys {
  say "monkey {.number} has inspected {.inspected-count} times";
}

my $score = [*] @monkeys.map({.inspected-count}).sort.tail(2);
say $score;
