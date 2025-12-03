#!/usr/bin/env raku

unit sub MAIN($file = 'input');

say sum $file.IO.slurp.split(',').map(*.split('-'))
  .map: -> (\b,\e) {
    sum (+b .. +e).grep: {
       .comb(
          ( 1..(.chars div 2) ).any
        ).unique == 1;
      }
  }
