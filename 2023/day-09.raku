#!/usr/bin/env raku

sub next-val(@seq is copy) {
  say "seq " ~ @seq;
  my @diffs;
  my $n = @seq.tail;
  my $a = -@seq.head;

  loop {
    my @next = @seq.rotor( 2 => -1).map: { - [-] @$_ }
    $n += @next.tail;
    last unless @next.first: so *;
    @seq = @next;
  }
  $n
}

say sum lines.map: { next-val(.words) }

