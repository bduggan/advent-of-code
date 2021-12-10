#!/usr/bin/env raku

sub most-common(@in) {
  ([Z] @in).map: { (.sum / .elems).round };
}

sub least-common(@in) {
  ([Z] @in).map: { 1 - (.sum / .elems).round };
}

my @in = eager lines().map: *.comb.eager;
my @ox = @in;
my @co = @in;

my $digit = 0;
loop {
  unless @ox.elems == 1 {
    my $c = most-common(@ox)[$digit];
    @ox .= grep: -> $l { $l[$digit] == $c };
  }
  unless @co.elems == 1 {
    my $c = least-common(@co)[$digit];
    @co .= grep: -> $l { $l[$digit] == $c };
  }
  last if @ox.elems == 1 && @co.elems == 1;
  $digit++;
}
my $ox = (@ox[0].join).parse-base(2);
my $co = (@co[0].join).parse-base(2);

say $ox * $co;
