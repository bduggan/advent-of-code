#!/usr/bin/env raku

use Repl::Tools;

multi infix:<eql>(@a,@b) { @a.join(',') eq @b.join(',') }
multi infix:<eql>(@a,$b) { @a == 1 && @a[0] == $b }
multi infix:<eql>($a,@b) { @b == 1 && @b[0] == $a }

sub count-em($pat,@seq is copy) {
 say "counting $pat vs " ~ @seq.raku;
 return 0 unless $pat.chars > 0;
 return 0 if @seq.sum + @seq - 2 > $pat.comb(/'#' | '?'/).elems;
 my @pats = $pat.split('.').grep: *.chars > 0;

 return 1 if $pat eq any(<? #>) && @seq eql (1);

 if @pats == 1 {
	 return 1 if @seq eql (1,1) && $pat.chars == 3;
   return 2 if @seq eql (1) && $pat.chars == 2;
   return 1 if @seq == 1 && $pat.chars == @seq[0];
   say "cannot divide $pat";
   return -1000;
 }

 my $first = @pats.shift;
 my \h = @seq.shift;
 if $first.chars == h && $first.contains('#') {
   # ### matches 3 or ###?# matches 5
   # Only one option.
   return count-em(@pats.join('.'),@seq);
 }

 if $first eq '??' && h == 1 {
   return 2 * count-em(@pats.join('.'),@seq);
 }

 if $first eq '???' && h == 1 && @seq[0] == 1 {
  # ??? vs 1 1
  @seq.shift;
  return count-em(@pats.join('.'),@seq);
 }

 say "notyet.  first $first, pats { @pats.raku }, seq { @seq.raku }";
 -100;
}

say count-em('?', @(1,));
say count-em('#', @(1,));
say count-em('###.???', [3,1,1]);
say count-em('???.###', @(1,1,3));
say count-em('.??..??...?##.', @(1,1,3));
