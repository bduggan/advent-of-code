#!/usr/bin/env raku

my @seeds = lines().head.split(':')[1].words;
my %maps;
my %next-state;
my ($from,$to);
my regex from { \w+ }
my regex to { \w+ }
for lines() {
  m/<from> '-to-' <to> ' ' map/ and do {
    ($from,$to) = (~$<from>, ~$<to>);
    next;
  }
  m/(\d+) ** 3 % ' '/ or next;
  my ($dst,$src,$len) = .words;
  %maps{ $from }.push: %( :$src, :$dst, :$len );
  %next-state{ $from } = $to;
}

my $state = 'seed';
my @vals = @seeds;
loop {
  %maps{ $state }:exists or last;
  my @ranges := %maps{$state} or die "no map for $state";
  @vals .= map: { find-next-val($state, $_, @ranges) }
  say "vals in state $state are " ~ @vals;
  $state = %next-state{ $state } or last;
}

say "final vals: " ~ @vals;
say "min val is " ~ @vals.min;

sub find-next-val( $state, $val, @ranges ) {
  say "finding next val for $val (in $state)";
  with @ranges.first: { .<src> <= $val < .<src> + .<len> } {
    say "found range $_";
    return $val - .<src> + .<dst>
  }
  return $val
}
