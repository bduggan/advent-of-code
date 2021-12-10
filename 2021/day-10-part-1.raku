#!/usr/bin/env raku

my $*in;

class X::Corrupted is Exception {
  has $.bad;
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
    die X::Corrupted.new(message => "corrupted: want $goal, but got $bad", :$bad);
  }
}

my %points =
 ')' => 3,
 ']' => 57,
 '}' => 1197,
 '>' => 25137 ;

my $points = 0;
for lines() -> $line {
  try {
    $*in = $line;
    g.parse($line) and next;
    CATCH {
        default {
          my $char = .bad or next;
          my $pts = %points{ $char } or do { note "no points for $char"; next; }
          $points += $pts;
        }
    }
  }
}

say $points;
