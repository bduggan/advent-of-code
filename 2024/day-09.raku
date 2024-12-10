#!/usr/bin/env raku

#my $in = $*IN.slurp;
my $in = '2333133121414131402';

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

sub recompute {
  @block-counts = 0;
  @free-spaces = 0;
  for @disk {
    when /\./ {
      @free-spaces.tail++;
      @block-counts.append(0) if @block-counts.tail;
    }
    when /\d/ {
      @block-counts.tail++;
      @free-spaces.append(0) if @free-spaces.tail;
    }
  }
}

recompute;

loop {
  last unless $moving-block > 0;

  my $from = @block-locations[ $moving-block ];
  my $to-move = @id-counts[ $moving-block ];
  say "maybe moving block id $moving-block from $from";

  my $space-index = @free-spaces.first( :k, { $_ >= $to-move } );
  next without $space-index;

  my $pos = @block-counts[0..($space-index)].sum + @free-spaces[0..($space-index-1)].sum;

  next if $pos > $from;
  @disk[ $pos .. $pos + $to-move - 1 ] = $moving-block xx *;
  @disk[ $from .. $from + $to-move - 1] = '.' xx *;

  recompute;

  NEXT { $moving-block--; }
}

say sum @disk.map({ /\d/ ?? $_ !! 0   }) Z* 0..*;

