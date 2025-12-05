#!/usr/bin/env raku

sub maxx($str,$digits) {
  my @out;
  my @nums = $str.comb;
  for 0..^$digits -> $d {
    my $max-val = max @nums[0 .. ( * - $digits + $d )];
    my $pos = @nums.first: :k, * == $max-val;
    @nums .= tail(@nums - 1 - $pos);
    @out.push: $max-val;
  }
  +@out.join;
}

say sum 'input.real'.IO.lines.map: { maxx($_, 12) }

