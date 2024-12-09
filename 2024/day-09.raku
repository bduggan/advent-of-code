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

my $total-free = sum @free-spaces;
my $total-blocks = sum @block-counts;
my @id-counts = @block-counts;

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
}

loop {
  last unless $moving-block > 0;

  my $from = @block-locations[ $moving-block ];
  my $to-move = @id-counts[ $moving-block ];
  say "maybe moving block id $moving-block from $from";

  my $space-index = @free-spaces.first( :k, { $_ >= $to-move } );
  next without $space-index;

  my $pos = @block-counts[0..($space-index)].sum + @free-spaces[0..($space-index-1)].sum;

  next if $pos > $from;
  @disk[ $pos .. $pos + $to-move - 1 ] = $moving-block xx *; #@disk[ $from - $to-move + 1 .. $from  ];
  @disk[ $from .. $from + $to-move - 1] = '.' xx *;

  recompute(@disk);

  NEXT { $moving-block--; }
}

say sum @disk.map({ /\d/ ?? $_ !! 0   }) Z* 0..*;

