#!/usr/bin/env raku

my $h = 0;
my $d = 0;

for lines() {
  /forward ' ' <(\d+)>/ and $h += $/;
  /up ' ' <( \d+ )>$/   and $d -= $/;
  /down ' ' <( \d+ )>$/ and $d += $/;
}
say $h * $d;

