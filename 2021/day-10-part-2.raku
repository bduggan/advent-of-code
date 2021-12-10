#!/usr/bin/env raku

my $*in;
my $*goal;

class X::Corrupted is Exception {
  has $.bad;
  has $.message;
}
class X::Incomplete is Exception {
  has $.goal;
  has $.message;
}

grammar g {
  rule TOP {
    <nest>+ 
  }
  rule nest {
   | '(' ~ ')' [ <nest>* ]
   | '{' ~ '}' [ <nest>* ]
   | '<' ~ '>' [ <nest>* ]
   | '[' ~ ']' [ <nest>* ]
  }
  method FAILGOAL($goal) {
    my $bad = $*in.substr(self.pos,1);
    $*goal = $goal;
    unless $bad {
      die X::Incomplete.new(message => "incomplete: want $goal", :$goal);
    }
    die X::Corrupted.new(message => "corrupted: want $goal, but got $bad", :$bad);
  }
}

my %points =
  ')' => 1,
  ']' => 2,
  '}' => 3,
  '>' => 4;

my @scores;
for lines() -> $line {
  $*in = $line;
  my $done = False;
  my $added = "";
  loop {
    $*goal = Nil;
    try {
      if g.parse($*in) {
        $done = True;
        last;
      }
      CATCH {
        when X::Corrupted {
          $done = True;
          last;
        }
        when X::Incomplete {
          my $goal = .goal.comb[1] // .goal;
          $*in ~= $goal;
          $added ~= $goal;
        }
      }
    }
  }
  next unless $added; # corrupted
  my $score = 0;
  for $added.comb -> $c {
    $score *= 5;
    $score += %points{ $c };
  }
  push @scores, $score;
}

say @scores.sort[ @scores.elems / 2];
