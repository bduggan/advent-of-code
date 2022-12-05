#!/usr/bin/env raku

my $in = q:to/IN/;
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3  

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
IN

my $crane-model =
   #"CrateMover 9001"; # part 2
   "CrateMover 9000"; # part 1
# $in = 'day-05.input'.IO.slurp;

my ($start,$moves) = $in.split("\n\n");
my @grid = $start.lines.map: {"$_ ".comb(/..../)};

my @trans = [Z] @grid; # transpose
my @start = @trans.map: *.reverse;
my @stacks = @start.map: { [ .map(*.trim).grep(*.so) ] }
@stacks.unshift("dummy"); # since stack numbers start at 1

# @stacks[1] is now ("1", "[Z]", "[N]")

my regex count { \d+ }
my regex stack { \d+ }

for $moves.lines -> $m {
  $m ~~ /:s move <count> from <stack> to <stack>/ or die "bad move";
  my ($count, $from, $to) = +$<count>, |@$<stack>;

  if $crane-model eq 'CrateMover 9001' {
    @stacks[$to].append: @stacks[ $from ].splice(* - $count);
  } else  {
    @stacks[$to].push: @stacks[ $from ].pop for 1..$count;
  }
}

say (@stacks[1..*].map: *.tail.comb[1]).join
