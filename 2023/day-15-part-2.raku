#!/usr/bin/env raku

sub hash($str) {
  my $cv = 0;
  for $str.trim.comb -> $c {
    my $code = $c.ord;
    die "bad input" if $code > 128;
    $cv += $code;
    $cv *= 17;
    $cv = $cv % 256;
  }
  $cv;
}

die "oops" unless hash('HASH') == 52;

my $in = 'input'.IO.slurp.trim;

my regex label { <[a..z]>+ }
my regex num { \d+ }
my regex op { '-' | ['=' <num> ] }

my @boxes;

for $in.split(',') {
  m/<label> <op>/ or die "could not match $_";
  my $label = ~$<label>;
  my $box = hash($label);
  #say "$_ --> box $box";
  if ~$<op> eq '-' {
    @boxes[ $box ] = [ @boxes[$box].grep( { .defined and.words[0] ne $label } ) ];
    next;
  }
  my $focal-length = +$<op><num>;
  @boxes[ $box ] //= [];
  if @boxes[ $box ].grep( *.words[0] eq $label ) {
    # case 1
    my $i = @boxes[ $box ].first(:k, *.words[0] eq $label );
    @boxes[ $box ][ $i ] = "$label $focal-length";
  } else {
    # case 2
    @boxes[ $box ].push: "$label $focal-length";
  }
  #NEXT {
  #  say "--- after { $_.raku }";
  #  for @boxes {
  #      say "box " ~ $++ ~ ': ' ~ .raku;
  #  }
  #  say "";
  #}
}

my $sum = 0;
for 0..256 -> $box-num {
  my @b := @boxes[ $box-num ] || [];
  next unless @b && @b.elems;
  say "box $box-num " ~ @b.raku;
  my $n = ($box-num + 1 ) * ( [+]  (1..@b) Z* @b.map(*.words[1]) );
  $sum += $n;
}
say $sum;

