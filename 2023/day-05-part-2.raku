#!/usr/bin/env raku

class Interval {
  has $.min is rw;
  has $.max is rw;
  method Str { "[$.min, $.max)" }
  method apply-map(Interval $map) {
    Interval.new: min => $.min + $map.offset, max => $.max + $map.offset;
  }
}

class Mapping is Interval {
  has $.offset;
  method Str { "[$.min, $.max) -> ($.offset)" }
}

sub transform-interval($state, $interval is copy, @mappings) {
  my @out;
  for @mappings.sort(+*.min) -> $map {
    next if $interval.max < $map.min or $interval.min > $map.max;
    when $interval.min <= $map.min < $map.max <= $interval.max {
      $interval.max = $map.min;
      @out.push: $interval.apply-map($map);
    }
    when $interval.min <= $map.min < $interval.max <= $map.max {
      $interval.max = $map.max;
      @out.push: $interval.apply-map($map);
      @out.push: $interval unless $interval.min == $map.min;
    }
    when $map.min < $interval.min < $interval.max <= $map.max {
      @out.push: $interval.apply-map($map);
    }
    when $map.min < $interval.min < $map.max <= $interval.max {
      @out.push: Interval.new( min => $interval.min, max => $map.max).apply-map($map);
      $interval.min = $map.max;
    }
  }
  @out = ( $interval ) unless @out.elems;
  @out;
}

sub MAIN($file) {
  my @lines = $file.IO.slurp.lines;
  my @seeds = @lines.shift.split(':')[1].words;
  my %maps;
  my %next-state;
  my ($from,$to);
  my regex from { \w+ }
  my regex to { \w+ }
  for @lines {
    m/<from> '-to-' <to> ' ' map/ and do {
      ($from,$to) = (~$<from>, ~$<to>);
      next;
    }
    m/(\d+) ** 3 % ' '/ or next;
    my ($dst,$src,$len) = .words;
    %maps{ $from }.push: Mapping.new: :min($src), :max($src + $len), :offset( $dst - $src );
    %next-state{ $from } = $to;
  }

  my $state = 'seed';
  my @intervals = @seeds.map: -> $min, $len { Interval.new( :$min, :max($min + $len) ) }

  loop {
    %maps{ $state }:exists or last;
    my @mappings := %maps{$state} or die "no map for $state";
    @intervals .= map: { |transform-interval($state, $_, @mappings) }
    $state = %next-state{ $state } or last;
  }
  say @intervals.sort( +*.min )[0].min
}

