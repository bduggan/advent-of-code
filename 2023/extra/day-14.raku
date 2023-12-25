sub tilt(@rows) {
  @rows.map: -> $str {
    $str.split('#').map( -> $chunk {
      my $os := $chunk.comb('O').join;
      $os ~ '.' x ($chunk.chars - $os.chars);
    }).join('#');
  }
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

sub elapsed($percent-done) {
  my $secs-passed = DateTime.now - INIT DateTime.now;
  say $percent-done ~ " in $secs-passed seconds";
  # if 5 seconds have passed and we are 30% done
  # estimated time is 
  #     30% == 5 / total
  #     total = 5 / 0.3
  my $est-seconds = $secs-passed / ( $percent-done / 100);
  my ($secs,$mins,$hours,$days) = $est-seconds.polymod( 60, 60, 24);
  say "estimate: $days days, $hours hours, $mins mins, $secs secs";
}

sub tilt-north(@in) {
  tilt( [Z] @in );
}
my $in = 'input'.IO.slurp;
my @in = $in.lines.map: *.comb.Array;
my @trans = [Z] @in;
my $load;
#for (1..1_000_000_000) {
#  elapsed( 100 * $_ / 1_000_000_000 ) if $_ %% 10_000;
  @trans = tilt(@trans);
#}
$load = load(@trans);
say $load;

# 1_000_000_000 times n s e w

