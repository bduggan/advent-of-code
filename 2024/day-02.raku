#!/usr/bin/env raku

my @rows = lines.map: *.words.cache;

sub part1(@rows) {
  +@rows.grep: -> @r {
     ([<] @r) || ([>] @r) and
     1 <= all(@r.rotor(2 => -1).map: { abs([-] @$_) }) <= 3;
  }
}

sub part2(@rows) {
  +@rows.grep: -> @p {
    so (0..^@p).grep: {
      part1(
        @( @p[ 0 .. $_ - 1, $_ + 1 .. * ].flat, )
      );
    }
  }
}

say part1(@rows);
say part2(@rows);


