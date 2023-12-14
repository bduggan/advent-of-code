my $in = 'input'.IO.slurp;

sub tilt(@rows) {
  my @new;
  for @rows -> @l {
    my $str = @l.join;
    loop {
      $str ~~ s:g/ '.' 'O'/O./ or last;
    }
    @new.push: $str;
  }
  @new;
}

sub load(@rows) {
  my $load = 0;
  for @rows {
    for .comb.grep(:k, 'O') -> $i {
      $load += ( .chars - $i )
    }
  }
  $load;
}

my @in = $in.lines.map: *.comb.Array;
my @trans = [Z] @in;
my $load = load( tilt(@trans) );
say $load;

# 1_000_000_000 times n s e w

