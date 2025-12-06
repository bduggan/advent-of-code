#!/usr/bin/env raku

sub add-range(@existing,$new) {
  my @next;
  my $found-overlap = False;
  for @existing.sort({ .min } ) -> $e {
    if $new.max < $e.min || $new.min > $e.max {
      push @next, $e;
      next;
    }
    if $e.min <= $new.min <= $new.max <= $e.max {
      $found-overlap = True;
      push @next, $e;
      next;
    }
    my $merged = min($new.min,$e.min) .. max($new.max,$e.max);
    push @next, $merged;
  }
  push @next, $new unless $found-overlap;
  @next;
}

my @ranges;

for 'input.real'.IO.lines {
  my ($s,$e) = .split('-');
  my $r = $s .. $e;
  @ranges = add-range(@ranges,$r);
}
loop {
  my @next;
  say "simplifying, have " ~ @ranges.elems;
  for @ranges -> $r {
    @next = add-range(@next,$r)
  }
  last if @next.elems == @ranges.elems;
  @ranges = @next;
}

say sum @ranges.map: { .max - .min + 1 }

