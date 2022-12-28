#!/usr/bin/env raku
unit sub MAIN(Bool :$real, :$part = 1);

my $in = <1 2 -3 3 -2 0 4>;
$in = 'day-20.input'.IO.slurp if $real;
my @nums = $in.words.map: +*;

sub mix-once($i, @a, @order) {
  return if @a[$i] == 0;
  my $new-position = ($i + @a[$i]) % (@a.elems - 1);
  return if $new-position == $i;
  if $new-position == 0  {
    # not necessary, but matches the example input sequence
    @a.push: @a.splice($i,1)[0];
    @order.push: @order.splice($i,1)[0];
  } else {
    @a.splice($new-position, 0, @a.splice($i,1));
    @order.splice($new-position, 0, @order.splice($i,1));
  }
  @a;
}

my @order = 0 ..^ @nums.elems;
my $key =  $part == 1 ?? 1 !! 811_589_153;
@nums = @nums Z* ($key) xx *;

my $next = 0;
my $iterations = $part == 1 ?? 1 !! 10;
for 1..$iterations {
  say "$_ of $iterations";
  for 0 ..^ @nums.elems -> $i {
    say "--> $i of " ~ @nums.elems if $i %% 1000;
    my $next = @order.first: :k, * == $i;
    mix-once($next,@nums,@order);
  }
}

my $zero = @nums.first: :k, * == 0;
say "grove coordinates:";
say sum
 @nums[ ($zero + 1000) % @nums.elems ],
 @nums[ ($zero + 2000) % @nums.elems ],
 @nums[ ($zero + 3000) % @nums.elems ]
;

