#!/usr/bin/env raku


sub check($str,@want) {
  say "checking $str {@want}";
  my regex nums { '#'+ }
  my regex dots { '.'+ }
  my $matches = 0;
  my @positions = $str.comb.grep(:k, * eq '?');
  my @opts = @positions.combinations;
  for @opts {
    with ++$ { say '    ' ~ (100 * $_ / @opts) ~ ' percent' if $_ %% 10000 }
    my @c = $str.comb;
    @c[@$_] = '#' xx *;
    given @c.map({ $_ eq '?' ?? '.' !! $_}).join {
       m/^^ [ <nums> | <dots> ]+ $$/;
       my @pat := @( $<nums>.map: *.chars );
       # say "{@pat.raku} vs {@want.raku}";
       $matches++ if (@pat eqv @want);
    }
  }
  $matches;
}

my atomicint $total = 0;
my atomicint $line = 0;
race for 'input'.IO.lines.race(batch => 10,degree => 16) {
  atomic-inc-fetch($line);
  say "line $line";
  my ($str,$want) = .split(' ');
  atomic-fetch-add($total, check($str,$want.split(',').map(+*)));
}
say $total;
