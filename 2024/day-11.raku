#!/usr/bin/env raku

my $in = '125 17';

my @nums = $in.words;

my %known;

sub get-rocks(@values, $blinks where * >= 0) {
  #say "getting { @values.raku } for blinks: $blinks";
  return @values if $blinks == 0;
  my @new = @values.flatmap: {
    my $value = $_;
    my $shortcuts  = %known{ $value };
    my $skip = $shortcuts.keys.grep({ $_ < $blinks && $_ < $value }).max;
    when $shortcuts{$skip}.defined {
      die "oops" if $blinks < $skip;
      get-rocks( $shortcuts{ $skip }, $blinks - $skip );
    }
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
  if @values == 1 {
    %known{ @values[0] }{ $blinks } = @new;
  }
  return @new;
}

my $blinks = 25;
#my $blinks = 6;
say get-rocks([ 125 ], $blinks).elems + get-rocks([ 17 ], $blinks).elems;
#say get-rocks([ 125 ], $blinks).elems + get-rocks([ 17 ], $blinks).elems;

