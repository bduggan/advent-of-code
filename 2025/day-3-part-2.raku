#!/usr/bin/env raku

sub maxx($str,$digits) {
my @out;

my @nums = $str.comb;

for 0..^$digits -> $d {
  my $max-val = max @nums[0 .. ( * - $digits + $d )];
  my $pos = @nums.first: :k, * == $max-val;
  @nums = @nums[$pos ^.. *];
  @out.push: $max-val;
}
+@out.join;
}

my $total;
for 'input.real'.IO.lines {
  $total += maxx($_, 12);
}
say $total;

