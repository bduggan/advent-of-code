#!/usr/bin/env raku

my $in = slurp $*IN;
my regex doordont { 'do()' | 'don\'t' }

my @muls = $in.comb(
/
| <doordont>
| [ mul '(' \d+ ',' \d+ ')' ]
/
);

my $ok = True;

my $sum = 0;
for @muls {
  if $_ ~~ / 'don\'t' / {
   $ok = False;
   next;
  }
  if $_ ~~ / 'do' / {
   $ok = True;
  }
  my @num = $_.comb( /\d+/ );
  next unless $ok;
  next unless @num == 2;
  $sum += [*] @num
}

say $sum;

