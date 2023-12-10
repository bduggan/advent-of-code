#!/usr/bin/env raku

my @lines = lines;
my @grid = @lines.map: *.comb;
my $r = @grid.first: :k, *.contains('S');
my $c = @grid[$r].first: :k, * eq 'S';

sub offset($dir) {
  $_ = $dir;
  return @( -1, 0  ) when 'N';
  return @(  0, 1  ) when 'E';
  return @(  1, 0  ) when 'S';
  return @(  0, -1 ) when 'W';
}

my @pos = $r, $c;
my $dir = 'N';
my $steps = 0;
loop {
  unless $dir {
    say "no dir, at { @pos } : @grid[ @pos[0] ][@pos[1]]";
    exit;
  }
  print "at {@pos}, going $dir...";
  @pos >>+=>> offset($dir);
  say "now at {@pos}";
  $steps += 1;
  given @grid[ @pos[0] ][ @pos[1] ] {
    say "found $_";
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
say "steps $steps";
say "halfway: " ~ ($steps / 2);
