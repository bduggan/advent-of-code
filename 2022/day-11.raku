#!/usr/bin/env raku

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

class Tester {
	has Int $.divisor;
  has Int $.true;
  has Int $.false;
  method test(Int $n)  {
		$n %% $.divisor ?? $.true !! $.false;
  }
}

class Monkey {
  has Int $.number;
	has @.items;
  has $.operation;
  has Tester $.tester;

  method inspect-and-throw(@other-monkeys) {
		while @.items.shift -> $item  {
			say "monkey $.number is inspecting $item";
			my \old = $item;
		  use MONKEY-SEE-NO-EVAL;
		  my $new-level = (EVAL $.operation) div 3;
			my $next-monkey = $.tester.test($new-level);
		  @other-monkeys[ $next-monkey ].receive($new-level);
			say "throwing item with level $new-level to $next-monkey";
    }
  }

	method receive($item) {
		@.items.push: $item;
  }
}

use Grammar::PrettyErrors;
grammar Monkey::Grammar does Grammar::PrettyErrors {
  token ws { \h* }
  token number { <[0..9]>+ }
  token op { '+' | '*' | '-' }
	rule TOP { <monkey>+ %% "\n"+ }
  rule monkey { "Monkey" <number> ":" \n <items> <operation> <test> }
  rule items { "Starting items: " <number>+ % "," \n }
  rule operation { "Operation: " "new =" <expr> \n }
  token expr { \N+ }

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
 				  operation => $<operation>.made,
				  tester => $<test>.made;
  }
 method items($/) {
		$/.make: $<number>.map: +*
 }
 method operation($/) {
		$/.make: "$<expr>"
 }
 method test($/) {
		$/.make: Tester.new(divisor => +$<divisor>, true => +$<true>, false => +$<false>)
 }
}

my $actions = Monkey::Actions.new;
my $match = Monkey::Grammar.parse($in, :$actions);
my @monkeys = $match.made;
for 1..20 -> $round {
	for @monkeys -> $monkey {
		$monkey.inspect-and-throw(@monkeys);
	}
  say "after round $round";
	for @monkeys {
		say "monkey {.number} has {.items.join(',')}"
	}
}
