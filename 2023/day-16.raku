
# my @grid = 'input'.IO.lines.map: *.comb.Array;
my $in = q:to/IN/;
.\.
...
.-.
...
IN
my @grid = $in.lines.map: *.comb.Array;

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
  has Str $.dir;  # N,S,E,W
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
      when '|'  { ... }
    }
    # stay in bounds
    return -1 unless self.in-bounds;
    return $new;
  }
}

my @rays = Ray.new: pos => [0,0], dir => 'E';
loop {
  for @rays -> $r {
    .say for @rays;
    given $r.move {
      when Ray { @rays.push: $_ }
      when -1 { @rays.pop }
      when Nil { }
    }
  }
  last unless @rays;
}

