#!/usr/bin/env raku

use Repl::Tools;

multi infix:<eql>(@a,@b) { @a.join(',') eq @b.join(',') }
multi infix:<eql>(@a,$b) { @a == 1 && @a[0] == $b }
multi infix:<eql>($a,@b) { @b == 1 && @b[0] == $a }

multi count-em(@pat, @seq) {
  return count-em(@pat.join('.'), @seq);
}

multi count-em($pat,@seq is copy) {
 say "counting $pat vs " ~ @seq.raku;
 return 0 unless $pat.chars > 0;
 return 0 if @seq.sum > $pat.comb(/'#' | '?'/).elems;
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
 if $first.chars == h {
   if $first.contains('#') {
		 # ### matches 3 or ###?# matches 5
		 # Only one option.
		 return count-em(@pats,@seq);
   }
   if @seq.sum == @pats.map(*.chars).sum {
		 return count-em(@pats,@seq);
   }
   if @seq.max < h {
		 return count-em(@pats,@seq);
   }
 }

 if $first eq '??' && h == 1 {
   return 2 * count-em(@pats,@seq);
 }

 if $first eq '???' && h == 1 && @seq[0] == 1 {
  # ??? vs 1 1
  @seq.shift;
  return count-em(@pats,@seq);
 }

 if @pats.map(*.chars).sum == @seq.sum {
   if !$first.contains('#') {
 			# ('????.######..#####.',[1,6,5]);
      return $first.chars * count-em(@pats,@seq);
   }
 }

 say "notyet.  first $first, h is { h } pats { @pats.raku }, seq { @seq.raku }";
 -100;
}

say count-em('????.######..#####.',[1,6,5]);
say count-em('????.#...#...',[4,1,1]);
say count-em('?', @(1,));
say count-em('#', @(1,));
say count-em('###.???', [3,1,1]);
say count-em('???.###', @(1,1,3));
say count-em('.??..??...?##.', @(1,1,3));
