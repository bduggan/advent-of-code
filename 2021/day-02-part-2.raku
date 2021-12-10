#!/usr/bin/env raku

my $h = 0;
my $d = 0;
my $a = 0;

for lines() {
  /up ' ' <( \d+ )>$/   and $a -= $/;
  /down ' ' <( \d+ )>$/ and $a += $/;
  /forward ' ' <(\d+)>/ and $h += $/ and $d += ( $a * $/ );
}

say $h * $d;

