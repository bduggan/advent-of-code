#!/usr/bin/env raku

my @cols = [Z] lines».words;

say sum ( [Z,] @cols».sort ).map: { abs([-] @$_ ) }

say sum @cols[0].map: { $_ * @cols[1].grep: * == $_ }

