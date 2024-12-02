#!/usr/bin/env raku

my @rows = lines.map: *.words.cache;

sub part1 {
  my $safe = 0;
  for @rows -> $r {
    next unless ([<] @$r) || ([>] @$r);
    my $max-diff = max $r.rotor(2 => -1).map: { abs([-] @$_) };
    next if $max-diff > 3;
    my $min-diff = min $r.rotor(2 => -1).map: { abs([-] @$_) };
    next if $min-diff < 1;
    $safe++;
  }
  say $safe;
}

sub part2 {
  my $safe = 0;
  for @rows -> $p {
    for 0..^$p.elems -> $e {
      my $r = flat $p[ (0 .. $e - 1), ($e + 1 .. *) ];
      next unless ([<] @$r) || ([>] @$r);
      my $max-diff = max $r.rotor(2 => -1).map: { abs([-] @$_) };
      next if $max-diff > 3;
      my $min-diff = min $r.rotor(2 => -1).map: { abs([-] @$_) };
      next if $min-diff < 1;
      $safe++;
      last;
    }
  }
  say $safe;
}

part1;
part2;


