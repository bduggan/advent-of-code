#!/usr/bin/env raku

my $in = q:to/IN/;
1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122
IN

# $in = slurp 'day-25.input';

my %map = <2 1 0 - => Z=> <2 1 0 -1 -2>;
my $total;
for $in.lines -> $num {
  $total += [+] $num.comb.map( { %map{$_} } ).reverse Z* (1,5,25 ... *);
}

my @all;
my @map = <0 1 2 = ->;
while $total {
  @all.unshift: @map[ $total % 5 ];
  $total = ($total + 2) div 5;
}

say @all.join;

# decimal SNAFU
#       0     0
#       1     1
#       2     2
#       3    1=
#       4    1-
#       5    10
#       6    11
#       7    12
#       8    2=
#       9    2-
#       10   20
#       11   21
#       12   22
#       13  1==
#       14  1=-
