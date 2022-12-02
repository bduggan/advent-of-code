#!/usr/bin/env raku

my %opponent-guide = A => 'rock', B => 'paper', C => 'scissors';
my %my-guide = X => 'rock', Y => 'paper', Z => 'scissors';
my %shape-scores = rock => 1, paper => 2, scissors => 3;
my %outcome-scores = loss => 0, draw => 3, win => 6;

my $in = q:to/IN/;
A Y
B X
C Z
IN
# $in = 'day-02.input'.IO.slurp;

my @shapes = <rock scissors paper>;
my %shape-index = @shapes.kv.Hash.invert;

sub outcome($me,$them) {
  return 'draw' if $me eq $them;
  return 'win' if (%shape-index{$me} + 1) % 3 == %shape-index{$them};
  return 'loss';
}

my $total = 0;
my $round = 0;
for $in.lines {
  my ($opponent, $me) = .split(' ');
  my $opponent-choice = %opponent-guide{ $opponent };
  my $my-choice = %my-guide{ $me };
  my $outcome = outcome($my-choice,$opponent-choice);
  my $score = %shape-scores{ $my-choice } + %outcome-scores{ $outcome };
  $total += $score;
  $round++;
  say "round $round: $my-choice vs $opponent-choice : $outcome  score: $score, total $total";
}

