#!/usr/bin/env raku

class Interval {
  has $.min is rw;
  has $.max is rw;
  method Str { "[$.min, $.max)" }
  method apply-map($map) {
    Interval.new: min => $.min + $map.offset, max => $.max + $map.offset;
  }
}

class Mapping is Interval {
  has $.offset;
  method Str { "[$.min, $.max) -> ($.offset)" }
}

sub transform-interval($state, Interval $i, @mappings) {
  my @out;
  for @mappings.sort(+*.min) -> $m {
    next if $i.max < $m.min or $i.min > $m.max;
    when $i.min <= $m.min < $m.max <= $i.max {
      $i.max = $m.min;
      @out.push: $i.apply-map($m);
    }
    when $i.min <= $m.min < $i.max <= $m.max {
      $i.max = $m.max;
      @out.push: $i.apply-map($m);
      @out.push: $i unless $i.min == $m.min;
    }
    when $m.min < $i.min < $i.max <= $m.max {
      @out.push: $i.apply-map($m);
    }
    when $m.min < $i.min < $m.max <= $i.max {
      @out.push: $i.new( min => $i.min, max => $m.max).apply-map($m);
      $i.min = $m.max;
    }
  }
  @out = ( $i ) unless @out.elems;
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

