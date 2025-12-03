#!/usr/bin/env raku

say
 sum
  'input'.IO.slurp.split(',')
  .map(*.split('-'))
  .map: {
    sum (+$^args[0] .. +$^args[1])
    .grep: {
       .comb(
          ( 1..(.chars div 2) ).any
        ).unique == 1;
      }
  }

