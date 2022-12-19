#!/usr/bin/env raku

use Repl::Tools;
unit sub MAIN(Bool :$real, Int :$max-moves, Bool :$*mark = True);

# password is 40442
# too low

my $in = q:to/BOARD/;
        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5
BOARD

$in = slurp 'day-22.input' if $real;

my ($board,$moves) = $in.split(/\n\n/);
my @moves = $moves.trim.comb: / <[0..9]>+ | R | L /;
my @grid = $board.lines.map: *.comb.list.Array;
my @dirs = <→ ↑ ← ↓>;

# row, col
my \max-col = max $board.lines».chars;
my \max-row = $board.lines.elems;

sub draw {
  for @grid.kv -> \r, @row {
    put r.fmt('%4d ') ~ @row.join;
  }
}

sub leading-pad(@l) {
  my $i = 0;
  $i++ while !defined(@l[$i]) || @l[ $i ] eq ' ';
  $i;
}

my @row-length = $board.lines.map: *.trim.chars;
my @row-pad = (0..^max-row).map: { leading-pad(@grid[$_;*]) }
my @col-pad = (0..^max-col).map: { leading-pad(@grid[*;$_]) }
my @col-length = (0..^max-col).map: { @grid[*;$_].grep(*.defined).join.trim.chars }

multi next-pos(\p, [0,1])  { [ p[0], ( ( p[1] + 1 - @row-pad[p[0]] ) % @row-length[p[0]] ) + @row-pad[p[0]] ] }
multi next-pos(\p, [0,-1]) { [ p[0], ( ( p[1] - 1 - @row-pad[p[0]] ) % @row-length[p[0]] ) + @row-pad[p[0]] ] }
multi next-pos(\p, [1,0] ) { [ (( p[0] + 1 - @col-pad[p[1]]) % @col-length[p[1]] ) + @col-pad[p[1]], p[1] ] }
multi next-pos(\p, [-1,0]) { [ (( p[0] - 1 - @col-pad[p[1]]) % @col-length[p[1]] ) + @col-pad[p[1]], p[1] ] }

my %cache;
multi trait_mod:<is>(Sub $sub, :$memoized) {
  $sub.wrap: -> |args { %cache{ $sub.WHICH }{ args.raku } //= callsame }
}

sub g(@pos) {
	@grid[@pos[0];@pos[1]]
}

sub try-move(@pos,$dir, $facing) {
 @grid[@pos[0];@pos[1]] = @dirs[$facing] if $*mark;
 my @next = next-pos(@pos,$dir);
 unless defined(g(@next)) {
   say "not defined!";
 }
 return @pos if g(@next) eq '#';
 unless $*mark {
   note "issue" && repl unless g(@next) eq '.';
 }
 @grid[@next[0];@next[1]] = @dirs[$facing] if $*mark;
 return @next;
}

my $facing = 0;
my $moves-made = 0;
sub move($n, @pos) {
  $moves-made++;
  say $moves-made ~ " : " ~ @pos.raku ~ " {@dirs[$facing]} $n";
	given @dirs[$facing] {
		when '→' { @pos = try-move(@pos, [0,1],  $facing ) for 0 ..^ $n; }
		when '←' { @pos = try-move(@pos, [0,-1], $facing)  for 0 ..^ $n; }
		when '↑' { @pos = try-move(@pos, [-1,0], $facing)  for 0 ..^ $n; }
		when '↓' { @pos = try-move(@pos, [1,0],  $facing ) for 0 ..^ $n; }
  }
  @grid[@pos[0];@pos[1]] = @dirs[$facing] if $*mark;
  last if $max-moves && $moves-made >= $max-moves;
  @pos;
}

my @p = [ 0, @grid[0].first(:k, * ne ' ') ];
for @moves -> $move {
  # say "instruction: " ~ $move.raku;
	given $move {
		when 'L' { $facing++; $facing %= 4 }
		when 'R' { $facing--; $facing %= 4 }
		when /<[0..9]>+/ { @p = move($move, @p) }
		default { die "error $move" }
  }
}

draw;

say "final pos is {@p.raku} and final facing is {@dirs[$facing]}";
my ($final-row, $final-col) = @p »+» [1,1];
my %facing-score = @dirs.keys Z=> <0 3 2 1>;
#The final password is the sum of 1000 times the row, 4 times the column, and the facing.
say "1000 * $final-row + 4 * $final-col + { %facing-score{$facing} }";
my $pass = 1000 * $final-row + 4 * $final-col + %facing-score{$facing};
say "password is $pass";

