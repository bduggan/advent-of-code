#!/usr/bin/env raku

my $in = q:to/IN/;
..............
..............
.......#......
.....###.#....
...#...#.#....
....#...##....
...#.###......
...##.#.##....
....#..#......
..............
..............
..............
IN

# $in = slurp 'day-23.input';

my @grid;
my $pad = 200;

sub g($r,$c) {
  return-rw @grid[$pad + $r; $pad + $c];
}

class Elf {
  has Int $.r;
  has Int $.c;
  has Int @.proposed-square[2];
  multi method is-occupied('N') { so g($.r - 1, any($.c - 1, $.c, $.c + 1)) }
  multi method is-occupied('S') { so g($.r + 1, any($.c - 1, $.c, $.c + 1)) }
  multi method is-occupied('W') { so g(any($.r - 1, $.r, $.r + 1), $.c - 1) }
  multi method is-occupied('E') { so g(any($.r - 1, $.r, $.r + 1), $.c + 1) }
  method wants-to-move {
    <N S W E>.first({ self.is-occupied($_) }).defined
  }
  method move {
    return unless @.proposed-square[0].defined;
    g($!r,$!c) = Nil;
    ($!r,$!c) = @.proposed-square;
    g($!r,$!c) = self;
  }
  my %vec = N => (-1,0), S => (1,0), W => (0,-1), E => (0,1);
  method propose($dir) {
    # say "elf {self} proposes moving $dir";
    @.proposed-square = [ $.r, $.c ] »+» %vec{$dir};
    @.proposed-square;
  }
  method reset {
    @.proposed-square = ( Nil, Nil );
  }
  method Str {
    "elf at $.r,$.c"
  }
}

my @elves;

for $in.lines.kv -> $r, $row {
  for $row.comb.kv -> $c, $col {
    next unless $col eq '#';
    my $elf = Elf.new: :$r, :$c;
    g($r,$c) = $elf;
    @elves.push: $elf;
  }
}

sub min-box {
  ( @elves».r.min, @elves».r.max, @elves».c.min, @elves».c.max ) X+ $pad
}

sub draw {
  my (\min-r,\max-r,\min-c,\max-c) := min-box;
  for @grid[min-r..max-r] -> $row {
    for @$row[min-c ..max-c] {
      if .defined { print '#' }
      else {print '.' }
    }
    print "\n";
  }
}

sub compute-score {
  # 1. find bounding rectangle
  my (\min-r,\max-r,\min-c,\max-c) := min-box;
  # 2. find holes
  sum @grid[min-r .. max-r;min-c .. max-c].grep({ !.defined }).elems
}

my $round = 0;
my @dirs = <N S W E>;
my $moved = True;
while $moved {
  $moved = False;
  $round++;
  say "round $round.  dirs: {@dirs}";
  my %proposed;
  for @elves -> $elf {
    $elf.reset;
    next unless $elf.wants-to-move;
    my $dir = @dirs.first: { !$elf.is-occupied($_) } or next;
    my $square = $elf.propose($dir);
    %proposed{ $square } //= 0;
    %proposed{ $square }++;
  }

  for @elves -> $elf {
    next unless $elf.proposed-square[0].defined;
    if %proposed{ ~$elf.proposed-square } > 1 {
      # say "sorry $elf";
      next;
    }
    # say "$elf gets to move";
    $elf.move;
    $moved = True;
  }
  @dirs .= rotate;
  if $round == 10 {
    my $score = compute-score;
    say $score;
  }
}

say "rounds $round";
