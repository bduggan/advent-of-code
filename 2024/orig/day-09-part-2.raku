#!/usr/bin/env raku

my $in = $*IN.slurp;
#my $in = '2333133121414131402';

my @in = $in.comb.list;
my @free-spaces;
my @block-counts;
my @block-locations;

my @disk;
my $id = 0;
loop {
  last unless @in;
  my $block = @in.shift;
  my $free = @in ?? @in.shift !! 0;
  @free-spaces.push: $free;
  @block-counts.push: $block;
  @block-locations.push: @disk.elems;
  @disk.append: $id xx $block;
  @disk.append: '.' xx $free;
  $id++;
}

#say @disk.join;

my $total-free = sum @free-spaces;
my $total-blocks = sum @block-counts;
my @id-counts = @block-counts;

use Repl::Tools;

my $moving-block = $id - 1;

sub recompute(@disk) {
  @block-counts = ();
  @free-spaces = ();
  my $current-block = 0;
  my $current-free = 0;
  for @disk {
      if $_ ne '.' {
        @block-counts[ $current-block ]++;
        $current-free++ if @free-spaces[$current-free].defined;
      } else {
        @free-spaces[ $current-free ]++;
        $current-block++ if @block-counts[$current-block].defined;
      }
  }
  #say @disk.join;
  #say @block-counts.raku;
  #say @free-spaces.raku;
  #repl;
}

loop {
  last unless $moving-block > 0;

  my $from = @block-locations[ $moving-block ];
  my $to-move = @id-counts[ $moving-block ];

  say "maybe moving block id $moving-block from $from";
  #repl;
  die "issue { @block-counts.raku }" unless (sum @block-counts) == $total-blocks;

  # Find first free space
  my $space-index = @free-spaces.first( :k, { $_ >= $to-move } );

  without $space-index {
    #say "couldn't find space";
    next;
  }

  my $pos = @block-counts[0..($space-index)].sum + @free-spaces[0..($space-index-1)].sum;

  next if $pos > $from;

  #say "space $space, blocks $blocks, moving $to-move from $from to $pos";
  #say "before: " ~ @disk.join;
  #repl;

  @disk[ $pos .. $pos + $to-move - 1 ] = $moving-block xx *; #@disk[ $from - $to-move + 1 .. $from  ];
  @disk[ $from .. $from + $to-move - 1] = '.' xx *;
  #say "after : " ~ @disk.join;
  #repl;
  # move $to-move from the end of @disk to position $pos;

  recompute(@disk);
  #@block-counts[* - 1] -= $to-move;
  #@block-counts[0] += $to-move;
  #@free-spaces[$space-index] -= $to-move;
  #@free-spaces[* - 1] += $to-move;

  NEXT { $moving-block--; }
}

#say @disk.join;

my $sum;
my $i = 0;
for @disk -> $d {
  next if $d eq '.';
  $sum += $d * $i;
  NEXT $i++;
}

say $sum;

