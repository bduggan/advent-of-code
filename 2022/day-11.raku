#!/usr/bin/env raku

my $*product;

my $in = q:to/IN/;
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
IN

# $in = 'day-11.input'.IO.slurp;

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
    # say "monkey number {self.number} has {@!items.elems} items";
		while @!items.shift -> $item  {
		  my $new-level = $.operator.eval($item);
			my $next-monkey = $.tester.test($new-level);
		  @other-monkeys[ $next-monkey ].items.push: $new-level % $*product;
      die "can't throw to myself" if $next-monkey == $.number;
      # say "throwing item with level $new-level to $next-monkey";
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
	next unless $round == 1 || $round == 20 || $round %% 1000;
  say "round $round";
	for @monkeys {
		# say "monkey {.number} has {.items.join(',')}"
	  say "monkey {.number} has inspected {.inspected-count} times";
	}
}

say "done";

my $score = [*] @monkeys.map({.inspected-count}).sort.tail(2);
say $score;
