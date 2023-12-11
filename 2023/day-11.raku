#!/usr/bin/env raku

sub transpose(@m) {
  [Z] @m
}

sub dump(@rows) {
  .say for @rows.map: *.join;
  say '--';
}

sub multi-blanks(@rows, $n, %multi) {
  my @new;
  for @rows.kv -> $i, @r {
    @new.push: @r;
    next unless @r.unique.elems == 1;
    %multi{ $i } = $n;
  }
  @new;
}

my @m = 'input'.IO.slurp.lines.map: *.comb.Array;

my %row-multiples;
my %col-multiples;

my $count = 2; # 1_000_000;
my @n = multi-blanks(@m, $count, %row-multiples);
my @o = transpose( multi-blanks( transpose( @n ), $count, %col-multiples ) );

my @galaxies;
for @o.kv -> $i, @row {
  for @row.kv -> $j, $c {
    next unless $c eq '#';
    @galaxies.push: ( $i, $j );
  }
}

say %row-multiples;
say %col-multiples;

my $sum;
for @galaxies.combinations(2) -> ($a,$b) {
  my $dist = 0;
  for $a[0] ^... $b[0] {
    $dist += %row-multiples{ $_ } // 1;
  }
  for $a[1] ^... $b[1] {
    $dist += %col-multiples{ $_ } // 1;
  }
  say ++$ ~ " pair $a $b, distance $dist";
  $sum += $dist;
}

say $sum;
