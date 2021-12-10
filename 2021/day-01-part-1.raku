#!/usr/bin/env raku

say [+] lines().rotor(2 => -1).map: { .[1] > .[0] }
