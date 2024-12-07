#!/usr/bin/env raku

my @in = lines;

sub eval(@nums is copy, @ops is copy where *.elems == @nums.elems - 1, $target) {
  my $total = @nums.shift;
  while @nums.shift -> \n {
    given @ops.shift {
      when '+'  { $total += n; }
      when '*'  { $total *= n; }
      when '||' { $total ~= n; }
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
    for @( [X] @( @operators xx (@nums - 1), ) ) -> @ops {
      next unless eval(@nums,@ops,$target);
      $sum ⚛+= $target;
      last;
    }
  }
  say $sum;
}

do-it(<* +>);    # part 1
do-it(<* + ||>); # part 2
 
