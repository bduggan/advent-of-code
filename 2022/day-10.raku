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
my $pixel = 0;
my @crt; # = '_' xx 240;
my $strength = 0;

loop {
  $cycle++;
  $strength += $cycle * $x if ($cycle + 20) %% 40;
  # x determines the middle of the sprite position.
  # check to see if this $pixel being drawn
  if ( $pixel % 40 == any($x - 1, $x, $x + 1) ) {
    @crt[ $pixel ] = '#' 
  } else {
    @crt[ $pixel ] = '.' 
  }
  $pixel = $cycle;

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

# part 1
say $strength;

# part 2
put .join for @crt.rotor(40);
