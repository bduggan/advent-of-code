#!/usr/bin/env raku

my @in = lines;

sub eval(@nums is copy, @ops is copy, $target) {
  die "incorrect number of ops { @nums.raku } vs { @ops.raku }" unless @ops == @nums - 1;
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

#my @OPS = '*', '+';
my @OPS = '*', '+', '||';
my @ok;
my $line = 0;
for @in {
  say "line " ~ $line++ ~ " of " ~ @in.elems ~ ' thread ' ~ $*THREAD.id;
  my ($target,$nums) = .split(':');
  my @nums = $nums.words.map: +*;
  my @candidates = [X] @( @OPS xx (@nums - 1) );
  if @nums == 2 {
    @candidates = @OPS;
  }
  for @candidates -> $ops {
    next unless eval(@nums,@$ops,$target) == $target;
    push @ok, $target;
    last;
  }
}
#say @ok.raku;
say [+] @ok;

