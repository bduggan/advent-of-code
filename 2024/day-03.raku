#!/usr/bin/env raku

my $in = slurp $*IN;

my regex do-or-dont { 'do()' | 'don\'t()' }
my regex mul { mul '(' \d+ ',' \d+ ')' }

sub part-one {
  my @muls = $in.comb( / <mul> /);
  say sum @muls.map: { [*] .comb( /\d+/ ) }
}

sub part-two {
  my @muls = $in.comb( / <do-or-dont> | <mul> /);
  my $ok = True;
  say sum @muls.map: {
    when / <do-or-dont> / {
      $ok = not so / 'don\'t' /;
      Empty;
    }
    [*] .comb( /\d+/ ) if $ok;
  }
}

part-one;
part-two;
