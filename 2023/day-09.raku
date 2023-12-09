#!/usr/bin/env raku

sub prev-val(@seq is copy) {
  say "seq " ~ @seq;
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
  my $prev = 0;
  for @f.reverse -> $l {
    $prev = $l - $prev;
  }
  return $prev;
}

say sum 'input'.IO.lines.map: { prev-val(.words) }
