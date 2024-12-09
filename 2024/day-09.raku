#!/usr/bin/env raku

my $in = '12345';

my @in = $in.comb.list;
my @free-spaces;
my @block-counts;
my @disk;
my $id = 0;
loop {
  last unless @in;
  my $block = @in.shift;
  my $free = @in ?? @in.shift !! 0;
  @free-spaces.push: $free;
  @block-counts.push: $block;
  @disk.append: $id xx $block;
  @disk.append: '.' xx $free;
  $id++;
}

say @disk.join;

my $total-free = sum @free-spaces;
my $total-blocks = sum @block-counts;

use Repl::Tools;

loop {
  die "issue { @block-counts.raku }" unless (sum @block-counts) == $total-blocks;
  my $space = @free-spaces.head;
  my $blocks = @block-counts.tail;
  my $to-move = min($space, $blocks);
  my $pos = @disk.first: :k, { $_ eq '.' };
  my $from = @disk.reverse.first: :k, { $_ ne '.'; };
  $from = @disk.elems - 1 - $from;

  #say "space $space, blocks $blocks, moving $to-move from $from to $pos";
  #say "before: " ~ @disk.join;

  @disk[ $pos .. $pos + $to-move - 1 ] = @disk[ $from - $to-move + 1 .. $from  ];
  @disk[ $from - $to-move + 1 .. $from ] = '.' xx *;
  say "after: " ~ @disk.join;
  # move $to-move from the end of @disk to position $pos;
  @block-counts[* - 1] -= $to-move;
  @block-counts[0] += $to-move;
  @free-spaces[0] -= $to-move;
  @free-spaces[* - 1] += $to-move;
  @block-counts.pop if @block-counts.tail == 0;
  @free-spaces.shift if @free-spaces.head == 0;

  last if $total-blocks == @disk.first: :k, { $_ eq '.' };
}

say @disk.join;

