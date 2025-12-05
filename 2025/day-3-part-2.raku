#!/usr/bin/env raku

sub maxx($str,$digits) {
my @out;

my @nums = $str.comb;

for 0..^$digits {
  my $digits-remaining = $digits - $_;
  my @vals = @nums[0 ..^ ( * - ($digits-remaining - 1) )];
  my $max-val = @vals.max;
  my $pos = @nums.first: :k, { $_ == $max-val };
  my $val = @nums[$pos];
  @nums = @nums[$pos^..*];
  @out.push: $val;
}
+@out.join;
}

my $total;
for 'input.real'.IO.lines {
  $total += maxx($_, 12);
}
say $total;

