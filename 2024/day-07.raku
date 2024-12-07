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
  my %done;
  my Lock $l .= new;
  race for @in.race {
    my ($target,@nums) = .split(/ ':' | ' ' /);
    race for @( [X] @( @operators xx (@nums - 1), ) ).race -> @ops {
      next unless eval(@nums,@ops,$target);
      $l.protect: { next if %done{ $target }++; }
      $sum ⚛+= $target;
      last;
    }
  }
  say $sum;
}

do-it(<* +>);    # part 1
do-it(<* + ||>); # part 2
 
