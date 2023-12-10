#!/usr/bin/env raku

my @lines = 'input.real'.IO.lines;
my @grid = @lines.map: *.comb;
my @path;
my $r = @grid.first: :k, *.contains('S');
my $c = @grid[$r].first: :k, * eq 'S';

sub offset($dir) {
  $_ = $dir;
  return @( -1, 0  ) when 'N';
  return @(  0, 1  ) when 'E';
  return @(  1, 0  ) when 'S';
  return @(  0, -1 ) when 'W';
}

my %box = %( '-' => '─', '|' => '│', 'L' => '└', 'J' => '┘', '7' => '┐', 'F' => '┌', 'S' => 'S' );
sub mark(@pos) {
  my $at = @grid[ @pos[0] ][ @pos[1] ];
  @path[ @pos[0] ][ @pos[1] ] = %box{ $at };
  die "what is $r" without %box{ $at }
}

my @pos = $r, $c;
my $dir = 'N';
# my $dir = 'E';
my $steps = 0;
loop {
  unless $dir {
    say "no dir, at { @pos } : @grid[ @pos[0] ][@pos[1]]";
    exit;
  }
  # print "at {@pos}, going $dir...";
  @pos >>+=>> offset($dir);
  # say "now at {@pos}";
  $steps += 1;
  given @grid[ @pos[0] ][ @pos[1] ] {
    mark(@pos);
    when 'S' {
      say 'done';
      last;
    }
    when '-' { next; }
    when '7' { $dir = { E => 'S', N => 'W' }{ $dir }; }
    when 'J' { $dir = { E => 'N', S => 'W' }{ $dir }; }
    when 'L' { $dir = { W => 'N', S => 'E' }{ $dir }; }
    when 'F' { $dir = { N => 'E', W => 'S' }{ $dir }; }
  }
}
#say "steps $steps";
#say "halfway: " ~ ($steps / 2);
my $total;
for @path -> $row {
  my $in = False;
  my $on = False;
  my $count = 0;
  next without $row;
  for @$row -> $c is copy {
    # '─', '│', '└',  '┘', '┐', '┌', 'S');
    $c //= ' ';
    if $c (<) <└ ┌> {
      #warn "error" if $on;
      $on = True;
    }
    if $c eq '│' {
      $in = !$in;
    }
    if $c eq '─' {
      # warn "error" unless $on;
    }
    if $c (<) ( '┘', '┐' ) {
      $on = False;
      $in = !$in;
    }
    if $c eq 'S' {
      # TODO
    }
    $count++ if $in;
    print $c;
  }
  #print $count.fmt(' %5d');
  print "\n";
  # say $row.map({ $_ // ' '}).join;
  $total += $count;
}
#say "total is $total";
# 647 is too high
#
