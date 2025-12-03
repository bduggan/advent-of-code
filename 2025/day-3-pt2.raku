#!/usr/bin/env raku
unit sub MAIN($file = 'input');
my $tot;
for $file.IO.lines {
  say "file line is $_";
  my $len = .chars;
  my @nums = .comb;
  my @consider = @nums;
  my ($pos,$val) = @nums.max(:kv);
  my $max = 0;
  my @digits = $val;
  loop {
    last if @digits == 12;
    @consider = @consider[$pos ^..^ @consider.elems];
    my $max-value = @consider.max(:kv);
    # find the first max such that there are 11 chars after it
    my $next-digit = @consider.kv.grep: -> $k, $v {
      $v >= $max-value && $k <= @consider.elems - 11
    }
    last without $pos;
    die 'what' without $next-digit;
    note "next digit is $next-digit";

    @digits.push: $next-digit[1];
    $pos = $next-digit[0] or die "missing pos";
    
    say "found maxes position $pos and value $val";
    @digits.push: $val;
  }
  $max = +@digits.join;
  say "max for $_ is $max";
  $tot += $max;
}
say $tot;


