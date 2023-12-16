my @lines = 'input.real'.IO.lines;
#my @lines = 'input'.IO.lines;
my @grid = @lines.map: *.comb.Array;
my \rows = @grid.elems;
my \cols = @grid[0].elems;

sub offset($dir) {
  $_ = $dir;
  return @( -1, 0  ) when 'N';
  return @(  0, 1  ) when 'E';
  return @(  1, 0  ) when 'S';
  return @(  0, -1 ) when 'W';
}

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
    return $new;
  }
}

sub energized-count($start-row, $start-col, $start-dir) {
  my %seen;
  my @energized = @lines.map: { [ '.' xx .chars ] };
  my @rays = Ray.new: pos => [$start-row,$start-col], dir => $start-dir;
  my %pruneable;
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
      #.say for @rays;
    }
    @rays = @rays.grep: *.in-bounds;
    @rays = @rays.grep: { not %pruneable{ .posdir }++ };
    last unless @rays;
  }

  sum @energized.map: *.comb.grep( * eq '#' );
}

sub elapsed($count, $percent-done) {
  #return unless $count %% 5;
  say "working on $count on thread { $*THREAD.id }";
  my $secs-passed = DateTime.now - INIT DateTime.now;
  #say $percent-done ~ " percent in $secs-passed seconds";
  # if 5 seconds have passed and we are 30% done
  # estimated time is
  #     30% == 5 / total
  #     total = 5 / 0.3
  my $est-seconds = $secs-passed / ( ($percent-done + 0.00001) / 100);
  my ($secs,$mins,$hours,$days) = $est-seconds.polymod( 60, 60, 24).map: { .fmt('%.1f') }
  say "estimate (thread { $*THREAD.id }) : $days days, $hours hours, $mins mins, $secs secs";
}

my Channel $c .= new;
my @all;
start loop { @all.push($c.receive) }
# race for (0..^rows).race(batch => 1, degree => 4) -> \r {
for (0..^rows) -> \r {
  say "row { r } of { rows }";
  $c.send: energized-count(r,0,'E');
  $c.send: energized-count(r,cols - 1,'W');
  elapsed(r, 100 * r / rows );
}
#race for (0..^cols).race(batch => 1, degree => 4) -> \c {
for (0..^cols) -> \c {
  #say "col { c } of { cols }";
  $c.send: energized-count(0,c,'S');
  $c.send: energized-count(0,rows - 1,'N');
  elapsed(c, 100 * c / cols );
}
say @all.max;
