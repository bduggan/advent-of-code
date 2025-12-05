#!/usr/bin/env raku

sub maxx($str,$digits) {

sub is-usable(@nums,$pos,:$digits-remaining!) {
  #say "is usable $pos?";
  die "hm" if $digits-remaining == 0;
  $pos < @nums.elems - ($digits-remaining - 1);
}

my @out;
my @nums = $str.comb;
for 0..^$digits {
  my $digits-remaining = $digits - $_;
  #say "digit $_, remaining $digits-remaining";
  my @ok-positions = (0..^(@nums.elems)).grep({ is-usable(@nums,$_, :$digits-remaining )});
  #say "ok positions are {@ok-positions}";
  my @vals = @nums[@ok-positions];
  #say "vals is " ~ @vals;
  my $max-val = @vals.max;
  #say "max val is $max-val";
  my $pos = @nums.first: :k, { $_ == $max-val };
  die "no value $max-val in {@nums}" without $pos;
  my $val = @nums[$pos];
  die "nothing at $pos" without $val;
  #say "pos is $pos";
  @nums = @nums[$pos^..*];
  #say "nums is now " ~ @nums;
  @out.push: $val;
}
+@out.join;
}

my $total;
for 'input.real'.IO.lines {
  $total += maxx($_, 12);
}
say $total;

