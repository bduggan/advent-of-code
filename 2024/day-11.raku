#!/usr/bin/env raku

my $in = '125 17';

my @nums = $in.words;

sub get-rocks(@values, $blinks) {
  #  say "getting { @values.raku } for blinks: $blinks";
  return @values if $blinks == 0;
  my @new = @values.flatmap: {
    when $_ == 0 { get-rocks([1], $blinks - 1) }
    when .chars %% 2 {
      @(   |get-rocks( @( +.substr(0, (.chars div 2) )), $blinks - 1)
        ,  |get-rocks( @( +.substr( (.chars div 2) )), $blinks - 1)
      )
    }
    default {
      get-rocks( @( $_ * 2024 ), $blinks - 1);
    }
    
  }
  return @new;
}

my $blinks = 25;
say get-rocks([ 125 ], $blinks).elems + get-rocks([ 17 ], $blinks).elems;
