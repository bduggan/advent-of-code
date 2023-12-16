
my $in = q:to/IN/;
.|.
...
...
IN
my @lines = 'input.real'.IO.lines;
#my @lines = 'input'.IO.lines;
#my @lines = $in.lines;
my @grid = @lines.map: *.comb.Array;
my @energized = @lines.map: { [ '.' xx .chars ] };

my \rows = @grid.elems;
my \cols = @grid[0].elems;

sub offset($dir) {
  $_ = $dir;
  return @( -1, 0  ) when 'N';
  return @(  0, 1  ) when 'E';
  return @(  1, 0  ) when 'S';
  return @(  0, -1 ) when 'W';
}

use Repl::Tools;

my $id = 0;

class Ray {
  has $.id = ++$id;
  has Int @.pos;  # row,col
  method row { @.pos[0] }
  method col { @.pos[1] }
  has Str $.dir;  # N,S,E,W
  method posdir {
    @.pos.join(',') ~ ' ' ~ $.dir;
  }
  method in-bounds {
    0 <= @!pos[0] < rows and 0 <= @!pos[1] < cols
  }
  method move {
    my $new = Nil;
    given @grid[ @!pos[0] ][ @!pos[1] ] {
      when '.'  { @!pos »+=» offset($!dir) }
      when '\\' { $!dir = { E => 'S', N => 'W', S => 'E', W => 'N' }{$!dir};
                  @!pos »+=» offset($!dir) }
      when '/'  { $!dir = { S => 'W', N => 'E', W => 'S', E => 'N' }{$!dir};
                  @!pos »+=» offset($!dir) }
      when '-'  {
                  if $!dir eq any(<E W>) {
                    @!pos »+=» offset($!dir)
                  } else {
                    $new = Ray.new: dir => 'E', pos => @!pos »+» offset('E');
                    $new = Nil unless $new.in-bounds;
                    $!dir = 'W'; @!pos »+=» offset($!dir);
                  }
                }
      when '|'  {
                  if $!dir eq any(<N S>) {
                    @!pos »+=» offset($!dir)
                  } else {
                    $new = Ray.new: dir => 'N', pos => @!pos »+» offset('N');
                    $new = Nil unless $new.in-bounds;
                    $!dir = 'S'; @!pos »+=» offset($!dir);
                  }
                }
    }
    # stay in bounds
    #return -1 unless self.in-bounds;
    return $new;
  }
}

my %seen;
my @rays = Ray.new: pos => [0,0], dir => 'E';
loop {
  #  say 'grid vs energized: ';
  #for @grid Z, @energized -> ($g,$e) {
  #  say $g ~ '  ' ~ $e;
  #}
  for @rays -> $r {
    @energized[ $r.row ][ $r.col ] = '#';
    given $r.move {
      when Ray { @rays.push: $_ unless %seen{ $_.posdir }++ }
      when -1 { @rays.pop }
      when Nil { }
    }
    @rays = @rays.grep: *.in-bounds;
    #.say for @rays;
  }
  last unless @rays;
}

my $count = sum @energized.map: *.comb.grep( * eq '#' );
say $count;
