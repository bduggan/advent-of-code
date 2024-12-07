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
    return False if $total > $target;
  }
  $total == $target
}

sub do-it(@operators) {
  my atomicint $sum = 0;
  race for @in.race {
    my ($target,$nums) = .split(':');
    my @nums = $nums.words.map: +*;
    my atomicint $found = 0;
    race for @( [X] @( @operators xx (@nums - 1), ) ).race -> @ops {
      last if $found;
      next unless eval(@nums,@ops,$target);
      $sum ⚛+= $target;
      $found ⚛= 1;
      last;
    }
  }
  say $sum;
}

do-it(<* +>); # part 1
do-it(<* + ||>); # part 2
 
