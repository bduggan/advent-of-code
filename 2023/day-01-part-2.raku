#!/usr/bin/env raku

my $in = q:to/DONE/;
oneight
DONE

$in = 'input'.IO.slurp;

my @digits = <zero one two three four five six seven eight nine>;
my %vals = @digits.kv.reverse;
%vals<zero>:delete;

my $tot;

for $in.lines {
  say $_;
	my @first = .comb(/<[0..9]> | @digits/);
  my $r = .flip;
  my @rdigits = @digits.map: *.flip;
  my @last = $r.comb(/<[0..9]> | @rdigits/);
  my $first-digit = (%vals{ @first[0] }) // @first[0];
  my $last-digit = (%vals{ @last[0].flip }) // @last[0];
  my $val = $first-digit ~ $last-digit;

  $tot += $val;
}

say $tot;

