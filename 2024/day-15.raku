#!/usr/bin/env raku

use Terminal::ANSI;
use Repl::Tools;

my ($maze,$moves) = 'real'.IO.slurp.split(/\n\n/);

my @grid = $maze.lines.map: *.comb.Array;

my \rows = @grid.elems;
my \cols = @grid[0].elems;

my Int @pos    = ((^rows) X (^cols)).first: { @grid[.[0]][.[1]] eq '@' }

my @moves = $moves.lines.join.comb;

my $move-number = 0;
for @moves -> \m {
  move-to(0,0);
  say "moving { m }";
  say "------------";
  for 0..^rows -> $r {
    say @grid[$r].join;
  }
  say "move number " ~ (++$) ~ " of " ~ @moves.elems;

  my @prev = @pos;
  given m {
    when '<' { @pos = try-move(:@pos, dir => [ 0, -1 ] ) }
    when '>' { @pos = try-move(:@pos, dir => [ 0, +1 ] ) }
    when '^' { @pos = try-move(:@pos, dir => [ -1, 0  ] ) }
    when 'v' { @pos = try-move(:@pos, dir => [  1, 0 ] ) }
  }
  @grid[ @prev[0] ][ @prev[1] ] = '.';
  @grid[ @pos[0] ][ @pos[1] ] = '@';
  my @blocks = ((^rows) X (^cols)).grep: { @grid[.[0]][.[1]] eq 'O' }
  my $score = sum @blocks.map: -> ($x, $y) { $x * 100 + $y };
  say " " x 100 for 1..5;;
  say "after move " ~ $move-number ~ " score is $score";
  $move-number++;
}

sub at(Int @x where @x == 2) {
  return-rw @grid[@x[0]][@x[1]] // die "nothing at { @x }";
}

sub try-move(:@pos where @pos[0] ~~ Int, :$dir!) {
  my @to := @pos »+» $dir;
  #say "trying to move from {@pos} to {@to} (direction { $dir })";
  return @pos if at(@to) eq '#';
  return @pos unless at(@to) eq '.' | '@' || try-move-block(@to, $dir);
  @pos »+» $dir;
}

sub try-move-block($from, $dir) {
  my @to := @$from »+» $dir;
  #say "trying to move block from {$from} to " ~ @to;
  if at(@to) eq '#' {
    # say "cannot move to {@to} in direction { $dir }";
  	return False 
  }
  given at(@to) {
    when '.' | '@' {
      at(@to) = 'O';
      at(@$from) = '.';
      return True;
    }
    when 'O' {
			my $pushed = try-move-block(@to, $dir);
			if $pushed {
				at(@to) = 'O';
				at(@$from) = '.';
			  return True;
      } else {
			  return False
      }
    }
    default {
      die "unexpected value "  ~ .raku;
    }
  }
}

