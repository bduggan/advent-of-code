#!/usr/bin/env raku

sub maxx($str,$digits) {

sub is-usable(@nums,$pos,:$digits-remaining!) {
  $pos < @nums.elems - ($digits-remaining - 1);
}

my @out;
my @nums = $str.comb;
for 0..^$digits {
  my $digits-remaining = $digits - $_;
  my @ok-positions = (0..^(@nums.elems)).grep({ is-usable(@nums,$_, :$digits-remaining )});
  my @vals = @nums[@ok-positions];
  my $max-val = @vals.max;
  my $pos = @nums.first: :k, { $_ == $max-val };
  my $val = @nums[$pos];
  @nums = @nums[$pos^..*];
  @out.push: $max-val;
}
+@out.join;
}

my $total;
for 'input.real'.IO.lines {
  $total += maxx($_, 12);
}
say $total;

