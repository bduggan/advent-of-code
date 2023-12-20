#!/usr/bin/env raku

unit sub MAIN($file = 'input');
use Repl::Tools;

my regex dir { L|R|U|D }
my regex count { \d+ }
my regex color { '(#' <( \w+ )> ')' }

class Segment {
  has @.start;
  has @.end;
  has Str $.corner-piece;
}

my @lines;
my @pos = 0, 0;

my %dirs = U => <-1 0>, D => <1 0>, L => <0 -1>, R => <0 1>;
my $prev-dir;

sub corner-piece($prev,$dir) {
  return '┌' without $prev;
  given $prev ~ $dir {
    when any('UL', 'RD') { return '┐' }
    when any('DL', 'RU') { return '┘' }
    when any('LU', 'DR') { return '└' }
    when any('UR', 'LD') { return '┌' }
  }
  return 'o'
}

my @segments;
my $min-row = 0;
my $max-row = 0;
my $min-col = 0;
my $max-col = 0;

for $file.IO.lines {
  m/:s <dir> <count> <color>/ or die "no match $_";
  #my $count = +$<count>;
  my $count = :16(~$<color>); # part 2
  my @v := %dirs{ $<dir> } »*» $count  or die "bad dir";  
  @segments.push: Segment.new: start => @pos, end => @pos »+» @v, corner-piece => corner-piece( $prev-dir, ~$<dir> );
  @pos »+=» @v;
  $min-row min= @pos[0];
  $min-col min= @pos[1];
  $max-row max= @pos[0];
  $max-col max= @pos[1];
  $prev-dir = ~$<dir>;
}

multi elapsed($count, :$total) {
  elapsed($count,  ($count * 100)/$total );
}
multi elapsed($count, $percent-done) {
  return unless $count %% 500000;
  my $secs-passed = DateTime.now - INIT DateTime.now;
  say $percent-done ~ " percent in $secs-passed seconds";
  # if 5 seconds have passed and we are 30% done
  # estimated time is
  #     30% == 5 / total
  #     total = 5 / 0.3
  my $est-seconds = $secs-passed / ( ($percent-done + 0.00001) / 100);
  my $remaining = $est-seconds - $secs-passed;
  my ($secs,$mins,$hours,$days) = $remaining.polymod( 60, 60, 24).map: { .fmt('%.1f') }
  say "remaining estimate (thread { $*THREAD.id }) : $days days, $hours hours, $mins mins, $secs secs";
}
say @segments;

say $max-row - $min-row;
say $max-col - $min-col;
my $total;
for $min-row .. $max-row {
  elapsed( ++$, total => ($max-row - $min-row) );
  for @segments {
    $total += 100;
  }
}

#  my $total = 0;
#  for @all-cols -> $c {
    # 1. determine whether c and next chars are one of └─┐ | ┌─┘ │
    # if so, change in vs out
    # otherwise count it
    # also if it's ' ' then count iff it is in
    # TODO
    #  }
#}

#my regex looptop { '┌' '─'* '┐' }
#my regex loopbot { '└' '─'* '┘' }
#my regex vert    { '└' '─'* '┐' | '┌' '─'* '┘' | '│' }

#say "calculating total (nb: avoid comb to make it faster)";

#my $total;
#@strings.map: {
#  $total += .comb.grep(* ne ' ').elems;
#  m/:s ^^ [ <looptop> | <loopbot> | <vert> ]* $$/ or die "bad line '$_'";
#  for $<vert><> {
#    $total += $^end.from - $^begin.to 
#  }
#}
#say $total;
