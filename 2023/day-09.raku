#!/usr/bin/env raku

sub get-val(@seq is copy, Bool :$prev) {
  my $n = @seq.tail;
  my @f = @seq.head;

  loop {
    @seq = @seq.rotor( 2 => -1).map: -> (\a,\b) { b - a }
    $n += @seq.tail;
    @f.push: @seq.head;
    last unless @seq.first: so *
  }
  return $n unless $prev;
  my $p = 0;
  for @f.reverse -> $l {
    $p = $l - $p;
  }
  return $p;
}

my @lines = lines;
say sum @lines.map: { get-val(.words) }
say sum @lines.map: { get-val(.words, :prev) }
