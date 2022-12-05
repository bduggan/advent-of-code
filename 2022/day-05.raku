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

my $crane-model = "CrateMover 9001"; # part 2
$in = 'day-05.input'.IO.slurp;

my ($start,$moves) = $in.split("\n\n");
my @grid = $start.lines.map: {"$_ ".comb(/..../)};

# transpose
my @trans = [Z] @grid;

# reverse and remove spaces and brackets
my @start = @trans.map: *.reverse.List;

# remove empties from the top
my @stacks = ( 'x', ); # extra at element 0
for @start {
  push @stacks, @[ .grep({ /\w | \d / }).map: *.trim ];
}

# say @stacks.raku;
# [
# 'x',
# ("1", "[Z]", "[N]"),
# ("2", "[M]", "[C]", "[D]"),
# ("3", "[P]")
# ]

my regex count { \d+ }
my regex stack { \d+ }

for $moves.lines -> $m {
  $m ~~ /:s move <count> from <stack> to <stack>/ or die "bad move";
  my $count = +$<count>;
  my ($from,$to) = +$<stack>[0], $<stack>[1];
  if $crane-model eq 'CrateMover 9001' {
    @stacks[$to].append: @stacks[ $from ].splice(* - $count);
  } else  {
    for 1..$count {
      @stacks[$to].push: @stacks[ $from ].pop;
    }
  }
}

say (@stacks[1..*].map: *.tail.comb[1]).join
