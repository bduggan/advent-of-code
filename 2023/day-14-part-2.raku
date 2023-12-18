unit sub MAIN($file = 'input');

multi rotate(@rows is copy, :$times = 1) {
  @rows = ([Z] @rows.map(*.comb.Array)).map: *.join.flip for 1..$times;
  @rows;
}

sub tilt-west(@rows) {
  @rows.map: -> $str {
      $str.split('#').map( -> $chunk {
        my $os := $chunk.comb('O').join;
        $os ~ '.' x ($chunk.chars - $os.chars);
      }).join('#');
  }
}
sub tilt-south(@rows) { rotate( tilt-west(rotate(@rows)), :3times); }
sub tilt-north(@rows) { rotate( tilt-west(rotate(@rows, :3times)), :1times); }
sub tilt-east(@rows)  { rotate( tilt-west(rotate(@rows, :2times)), :2times); }

sub load(@rows) {
  sum @rows.map: {
    sum .comb.grep(:k, 'O').map: -> $i { .chars - $i }
  }
}

my @in = $file.IO.slurp.lines.map: ~*;
my %seen;
my $i = 1;
my $target = 1_000_000_000;
loop {
  if %seen{@in.raku} -> $old {
    if ($target - $i + 1) %% ($old - $i) {
      say load(rotate(@in,:3times));
      last;
    }
  }
  %seen{@in.raku} = $i;
  @in = tilt-north(@in);
  @in = tilt-west(@in);
  @in = tilt-south(@in);
  @in = tilt-east(@in);
  $i++;
  say "cycle $i";
}
