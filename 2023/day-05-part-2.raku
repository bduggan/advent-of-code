#!/usr/bin/env raku

class Interval {
  has $.min is rw;
  has $.max is rw;
  method TWEAK {
    say "$.min >= $.max" unless $.min < $.max;
    warn "$.min >= $.max" unless $.min < $.max;
  }
  method check {
    unless $.min < $.max {
      say "$.min >= $.max";
      warn "$.min >= $.max";
      return False;
    }
    True;
  }

  method len { $.max - $.min }

  method gist { "[$.min, $.max)" }
  method Str { "[$.min, $.max)" }

  method intersects(Interval $other) {
    not ($.max < $other.min or $.min > $other.max)
  }
  method apply-map(Interval $map) {
    Interval.new: min => $.min + $map.offset, max => $.max + $map.offset;
  }
}

class Mapping is Interval {
  has $.dst; # destination start
  has $.offset;
  method gist { "[$.min, $.max) -> {$.offset}" }
  method Str { "[$.min, $.max) -> ($.offset)" }
}

sub transform-interval($state, $interval is copy, @mappings) {
  say "xform interval $interval";
  my @out;
  for @mappings.sort(+*.min) -> $map {
    say "checking map $map vs interval $interval";
    next if $interval.max < $map.min;
    next if $interval.min > $map.max;
    when $interval.min <= $map.min < $map.max <= $interval.max {
      say "IMMI interval $interval map $map";
      $interval.max = $map.min;
      @out.push: $interval.apply-map($map);
      $interval.check;
    }
    when $interval.min == $map.min < $map.max <= $interval.max {
      say "IMMI interval $interval map $map";
      @out.push: $interval.apply-map($map);
      $interval.check;
    }
    when $interval.min == $map.min < $interval.max <= $map.max {
      say "IMIM interval $interval map $map";
      @out.push: $interval.apply-map($map);
    }
    when $interval.min < $map.min < $interval.max <= $map.max {
      say "IMIM interval $interval map $map";
      $interval.max = $map.max;
      $interval.check;
      @out.push: $interval.apply-map($map);
      @out.push: $interval;
    }
    when $map.min < $interval.min < $interval.max <= $map.max {
      say "MIIM interval $interval map $map";
      @out.push: $interval.apply-map($map);
      $interval = Nil;
      last;
    }
    when $map.min < $interval.min < $map.max <= $interval.max {
      say "MIMI: interval $interval map $map";
      my $sub-interval = Interval.new:
        min => $interval.min,
        max => $map.max;
      @out.push: $sub-interval.apply-map($map);
      $interval.min = $map.max;
      $interval.check;
    }
    when $interval.min < $map.min == $interval.max <= $map.max {
      next;
    }
    warn "TODO: interval $interval map $map";
  }
  @out = ( $interval ) unless @out.elems;
  @out;
}

sub MAIN($file) {
  my @lines = $file.IO.slurp.lines;
  my @seeds = @lines.shift.split(':')[1].words;
  # @seeds = 79, 14; # XXX
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
    %maps{ $from }.push: Mapping.new: :min($src), :max($src + $len), :$dst, :offset( $dst - $src );
    %next-state{ $from } = $to;
  }

  my $state = 'seed';
  my @intervals = @seeds.map: -> $min, $len { Interval.new( :$min, :max($min + $len) ) }

  loop {
    say "doing state $state";
    %maps{ $state }:exists or last;
    my @mappings := %maps{$state} or die "no map for $state";
    @intervals .= map: { |transform-interval($state, $_, @mappings) }
    say "done with intervals for state $state: " ~ @intervals;
    $state = %next-state{ $state } or last;
  }
  say "done";
  say @intervals.sort( *.min );
}

