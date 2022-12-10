#!/usr/bin/env raku

my $in = q:to/IN/;
noop
addx 3
addx -5
IN

$in = 'day-10.input2'.IO.slurp;

my @prog = $in.lines;
my $cycle = 0;
my $x = 1;
my $cpu-running= 0;
my &queued;
my $strength = 0;

loop {
  $cycle++;
  say "during cycle $cycle, x is $x" if ( $cycle + 20 ) %% 40;
  $strength += $cycle * $x if ($cycle + 20) %% 40;
  if $cpu-running {
    $cpu-running--;
    queued() if $cpu-running == 0;
    next;
  }
  my $inst = @prog.shift or last;
  given $inst {
    when 'noop' {
      next;
    }
    when /:s addx <('-'? \d+)> $/ {
      my $add = +$/;
      $cpu-running = 1;
      &queued = -> { $x += $add; }
    }
    default {
      die "unknown instruction $inst";
    }
  }
}

say $strength

