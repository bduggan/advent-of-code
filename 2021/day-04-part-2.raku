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

my %done;
my $called;
for @nums -> $n {
  for @boards.kv -> $k, $board is rw {
    next if %done{ $k };
    $board ~~ s/<|w> $n <|w>/X/;
    with winner($board) {
      %done{ $k } = True;
      $winner = $_;
      $called = $n;
      last if %done.keys == @boards;
    }
  }
}

say $called * [+] flat $winner.map: { .grep({ $_ ne 'X'}) };
