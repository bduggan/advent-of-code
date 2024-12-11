#!/usr/bin/env raku

my $in = '125 17';

my @nums = $in.words;

sub blink(@nums) {
  my @new;
  for @nums {
    when $_ == 0 {
      @new.append: 1;
    }
    when .chars %% 2 {
      @new.append: +.substr(0, (.chars div 2));
      @new.append: +.substr( (.chars div 2) );
    }
    @new.append: +($_ * 2024);
  }
  #say @new;
  @new;
}

say @nums;
loop {
  @nums = blink(@nums);
  say ++$ ~ ' : ' ~ @nums.elems;
  last if ++$ == 75;
}

say @nums.elems;
