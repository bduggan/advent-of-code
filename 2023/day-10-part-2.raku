#!/usr/bin/env raku

# 1. modify "NB" below and add the right direction for start.
# 2. run this, store the output in "path"
# 3. modify the output again and change S into the right character
# 4. run parse.raku to count how much is in the inside

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
}

my @pos = $r, $c;
my $dir = 'N';   # NB: adjust this for start
# my $dir = 'E';
my $steps = 0;
loop {
  @pos >>+=>> offset($dir);
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

my $total;
for @path -> $row {
  next without $row;
  for @$row -> $c {
    print $c // ' ';
  }
  print "\n";
}

