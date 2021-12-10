my @parts = lines().join("\n").split(/\n\n/);
my @nums = @parts.shift.split(',');
my @boards = @parts;
my $winner;

sub winner($b) {
  my @grid = $b.lines.map: { eager .words };
  return @grid if @grid.grep: { .grep(/X/) == 5 }
  return @grid if ([Z] @grid).grep: { .grep(/X/) == 5 }
  return Nil
}

my $called;
for @nums -> $n {
  $called = $n;
  for @boards -> $board is rw {
    $board ~~ s/<|w> $n <|w>/X/;
    last if $winner = winner($board);
  }
  last if $winner;
}

say $called * [+] flat $winner.map: { .grep({ $_ ne 'X'}) };
