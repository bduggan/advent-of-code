#!/usr/bin/env raku

my $in = slurp '/tmp/real';
my regex doordont { 'do()' | 'don\'t' }

my @muls = $in.comb(
/
| <doordont>
| [ mul '(' \d+ ',' \d+ ')' ]
/
);

say @muls;
my $ok = True;

my $sum = 0;
for @muls {
  say "we have $_";
  if $_ ~~ / 'don\'t' / {
   say 'DONT';
   $ok = False;
   next;
  }
  if $_ ~~ / 'do' / {
   say 'DO';
   $ok = True;
  }
  my @num = $_.comb( /\d+/ );
  say "num is " ~ @num;
  next unless $ok;
  next unless @num == 2;
  $sum += [*] @num
}

say $sum;

