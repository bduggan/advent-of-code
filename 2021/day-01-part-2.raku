#!/usr/bin/env raku

my @lines = lines;

say [+] @lines Z< @lines.tail(* - 3);

