#!/usr/bin/env raku

my @in = lines;

sub eval(@nums is copy, @ops is copy where *.elems == @nums.elems - 1, $target) {
  my $total = @nums.shift;
  while @nums {
    given @ops.shift {
      when '+' { $total += @nums.shift; }
      when '*' { $total *= @nums.shift; }
      when '||' { $total ~= @nums.shift; }
      default { fail "unknown operator: $_" }
    }
    return -1 if $total > $target;
  }
  $total;
}

sub do-it(@operators) {
  my atomicint $sum = 0;
  race for @in.race {
    my ($target,@nums) = .split(/ ':' | ' ' /);
    for [X] @( @operators xx (@nums - 1), ) -> $ops {
      next unless eval(@nums,@$ops,$target) == $target;
      $sum ⚛+= $target;
      last;
    }
  }
  say $sum;
}

do-it(<* +>); # part 1
do-it(<* + ||>); # part 2
 
