#!/usr/bin/env raku

# part two

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
  my @counts = @disk.join.match(/ ( [\d+] | ['.'+] )+ /, :g)[0][0].map: *.chars;
  @block-counts = @counts.pairup.map: *.key;
  @free-spaces = @counts.pairup.map: *.value;
}

loop {
  last unless $moving-block > 0;
  my $from = @block-locations[ $moving-block ];
  my $to-move = @id-counts[ $moving-block ];
  my $space-index = @free-spaces.first( :k, { $_ >= $to-move } );
  next without $space-index;

  my $pos = @block-counts[0..($space-index)].sum + @free-spaces[0..($space-index-1)].sum;
  next if $pos > $from;

  @disk[ $pos .. $pos + $to-move - 1 ] = $moving-block xx *;
  @disk[ $from .. $from + $to-move - 1] = '.' xx *;

  recompute(@disk);
  NEXT { $moving-block--; }
}

say sum @disk.map({ /\d/ ?? $_ !! 0   }) Z* 0..*;

