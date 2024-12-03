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
  my $sum = 0;
  for @muls {
    if / 'don\'t' / { $ok = False; next; }
    if / 'do' / { $ok = True; next; }
    $sum += [*] .comb( /\d+/ ) if $ok;
  }
  say $sum;
}

part-one;
part-two;
