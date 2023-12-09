#!/usr/bin/env raku

sub get-val(@seq is copy, Bool :$prev) {
  my @diffs;
  my $n = @seq.tail;
  my @f = @seq.head;

  loop {
    my @next = @seq.rotor( 2 => -1).map: { - [-] @$_ }
    $n += @next.tail;
    @f.push: @next.head;
    last unless @next.first: so *;
    @seq = @next;
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
