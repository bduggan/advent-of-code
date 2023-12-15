use Repl::Tools;

#multi rotate(@in) {
#  ([Z] @in.map(*.comb.Array)).map: *.join.flip;
#}

multi rotate(@in, :$times = 1) {
  my @out = @in;
  for 1..$times {
    @out = ([Z] @out.map(*.comb.Array)).map: *.join.flip;
  }
  @out;
}

sub tilt-west(@rows) {
  @rows.map: -> $str {
      $str.split('#').map( -> $chunk {
        my $os := $chunk.comb('O').join;
        $os ~ '.' x ($chunk.chars - $os.chars);
      }).join('#');
  }
}

sub tilt-south(@rows) {
  rotate( tilt-west(rotate(@rows)), :3times);
}

sub tilt-north(@rows) {
  rotate( tilt-west(rotate(@rows, :3times)), :1times);
}

sub tilt-east(@rows) {
  rotate( tilt-west(rotate(@rows, :2times)), :2times);
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

sub dump(@rows, $str = Nil) {
  say '─' x 20;
  if $str {
    say $str.indent(3);
    say '─' x 20;
  }
  .indent(5).say for @rows;
}

my $in = 'input'.IO.slurp;
my @in = $in.lines.map: ~*;
my %seen;
my $i = 1;
dump(@in,'start');
my $target = 1_000_000_000;
loop {
  if %seen{@in.raku} -> $old {
    say "state in cycle $i was seen in cycle $old";
    if ($target - $i + 1) %% ($old - $i) {
      say "$target will be reached from this state";
      say load(rotate(@in,:3times));
      exit;
    }
    # dump(@in);
  }
  %seen{@in.raku} = $i;
  @in = tilt-north(@in);
  @in = tilt-west(@in);
  @in = tilt-south(@in);
  @in = tilt-east(@in);
  #dump(@in, "after cycle $i");

  $i++;
  say "val in cycle $i is " ~ load(rotate(@in,:3times));
  last if $i > 100;
}
say load(@in);

# 1_000_000_000 times n w s e

