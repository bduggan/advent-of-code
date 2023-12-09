#!/usr/bin/env raku

sub get-val(@seq is copy) {
  my $n = @seq.tail; # next
  my @f = @seq.head; # first

  while @seq.grep(so *) {
    @seq = @seq.rotor(2 => -1).map: -> (\a,\b) { b - a }
    $n += @seq.tail;
    @f.push: @seq.head;
  }
  my $p = 0;
  @f.reverse.map: { $p = $_ - $p }
  return @( $n, $p );
}

my @lists = lines.map: { get-val(.words) }
say [+] @lists».[0]; # part 1
say [+] @lists».[1]; # part 2
