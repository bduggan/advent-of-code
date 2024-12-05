#!/usr/bin/env raku

my ($rules, $lists) = $*ARGFILES.slurp.split("\n\n");

my %must-come-before;

sub sorter($a,$b) {
  if $b ∈ %must-come-before{ $a } {
    return 1
  }
  return -1;
}

for $rules.lines {
  my ($x,$y) = .split('|');
  %must-come-before{ $y }.push: $x;
}

my @middles;
my @middles-sorted;

for $lists.lines {
  my @nums = .split(',');
  my $ok = True;
  for @nums.kv -> \i, \n {
     my @after = @nums[ i + 1 .. * ];
     if @after ∩ %must-come-before{ n } {
       $ok = False;
       my %int = @after ∩ %must-come-before{ n };
       last;
     }
  }
  if $ok {
    @middles.push: @nums[ @nums div 2 ];
  } else {
    my @new = @nums.sort( &sorter );
    @middles-sorted.push: @new[ @nums div 2 ];
  }
}

say @middles.sum;
say @middles-sorted.sum;

