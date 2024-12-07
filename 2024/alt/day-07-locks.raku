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
  my %found;
  my $lock = Lock.new;
  for @in {
    my ($target,$nums) = .split(':');
    my @nums = $nums.words.map: +*;
    race for @( [X] @( @operators xx (@nums - 1), ) ).race -> @ops {
      $lock.protect: {
        last if %found{$target};
      }
      next unless eval(@nums,@ops,$target);
      $lock.protect: {
        last if %found{$target};
        %found{$target} = True;
      }
      $sum ⚛+= $target;
      last;
    }
  }
  say $sum;
}

do-it(<* +>); # part 1
do-it(<* + ||>); # part 2
 
