#!/usr/bin/env raku

my @in = lines().map: *.comb;
my @cols = [Z] @in;
my @gamma;
my @eps;
for @cols {
  @gamma.push: (.sum / .elems).round;
  @eps.push: 1 - @gamma[*-1];
}
@gamma.= reverse;
@eps.= reverse;
say (@gamma Z* (1,2,4...*)).sum * (@eps Z* (1,2,4...*)).sum;
