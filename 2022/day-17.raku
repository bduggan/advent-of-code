#!/usr/bin/env raku

use lib $*HOME.child('raku-repl-tools/lib');
use Repl::Tools;
use Terminal::UI 'ui';
unit sub MAIN(Bool :$quiet, Int :$stop-at = 2023, Int :$repl-at, Bool :$ui);

my $in = '>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>';
$in = trim slurp 'day-17.input';

my $*total-rocks;
my %states;

if ($ui) {
  ui.setup: heights => [fr => 1, 5];
  ui.panes[0].auto-scroll = False;
}

sub d($str) {
  return if $ui;
  say $str;
}

my $rock-id-seq = 0;
class Rock {
  has $.id;
  has @.shape;
  has $.top is rw;
  has $.left is rw = 2;

  # @.bottom is an array of distances to the row below the last.
  # It is all zeros, when the bottom is flat.
  has @.bottom;

  method TWEAK {
    if @!bottom == 0 {
      @!bottom = 0 xx self.width
    }
    $!id = $rock-id-seq++;
  }

  method height {
    self.shape.elems
  }
  method width {
    self.shape[0].chars
  }
  method Str {
    '{' ~ self.shape.join("\n") ~ " (top $.top,left $.left)" ~ '}';
  }
}

my $frame = 0;

sub rocks-height(@cave) {
  @cave.map({ .max == 1 }).sum
}

sub show-cave-and-rock-ui(@cave,$rock) {
  my \t = ui.panes[0];
  t.clear;
  my $str;
  for @cave.reverse.kv -> $row, $data {
    $str = ' | ';
    my $in-shape = $rock.top - $rock.height < (@cave - $row - 1) <= $rock.top;
    my $shape-row = $rock.top - ( @cave - $row - 1 );
    for $data.kv -> $i, $v {
      my $shape-col = $i - $rock.left;
      if   0 <= $shape-col < $rock.width
         && $in-shape
         && $rock.shape[$shape-row].comb[$shape-col] eq '#' {
        $str ~= "@";
      } elsif $v == 1 {
        $str ~= '#'
      } elsif $v == 0 {
        $str ~= '.'
      }
    }
    $str ~= " |";
    t.put($str);
  }
  t.put(" +---------+");
  my $height = rocks-height(@cave);
  t.put("height is $height");
  ui.panes[1].put: "rocks: $*total-rocks, height $height"
}

sub show-cave-and-rock(@cave,$rock) {
  return show-cave-and-rock-ui(@cave,$rock) if $ui;
  return if $quiet;
  d "frame $frame";
  for @cave.reverse.kv -> $row, $data {
    print ' | ';
    my $in-shape = $rock.top - $rock.height < (@cave - $row - 1) <= $rock.top;
    my $shape-row = $rock.top - ( @cave - $row - 1 );
    for $data.kv -> $i, $v {
      my $shape-col = $i - $rock.left;
      if   0 <= $shape-col < $rock.width
         && $in-shape
         && $rock.shape[$shape-row].comb[$shape-col] eq '#' {
        print "@";
      } elsif $v == 1 {
        print '#'
      } elsif $v == 0 {
        print '.'
      }
    }
    print " |\n";
  }
  print " +---------+\n";
  d "height is " ~ rocks-height(@cave);
}

sub show-cave(@cave, Bool :$force) {
  return if $quiet && !$force;
  print "\n";
  for @cave.reverse {
    print ' | ';
    for .<> {
      print '#' when 1;
      print '.' when 0;
    }
    print " | \n";
  }
  print " +─────────+\n";
  d "height: " ~ rocks-height(@cave);
}

my @rock-types =
  Rock.new(shape => ('####',)),
  Rock.new(shape => (' # ','###',' # '), bottom => (1,0,1)),
  Rock.new(shape => ('  #','  #','###')),
  Rock.new(shape => ('#','#','#','#')),
  Rock.new(shape => ('##','##'));

multi push-rock('>', Rock :$rock, :@cave) {
  $frame++;
  ui.panes[1].put: "right 1 frame $frame" if $ui;
  d 'push >' unless $quiet;
  repl if $repl-at && $frame == $repl-at;
  my $can-move = True;
  for $rock.shape.kv -> $i, $row {
    my \r = $row.trim-trailing;
    with r.chars + $rock.left {
      if $_ >= 7 or @cave[ $rock.top - $i; $_ ] == 1 {
        $can-move = False;
        last;
      }
    }
  }
  $rock.left++ if $can-move;
  return $can-move;
}
multi push-rock('<', Rock :$rock, :@cave) {
  $frame++;
  ui.panes[1].put: "left 1 frame $frame" if $ui;
  d 'push <' unless $quiet;
  repl if $repl-at && $frame == $repl-at;
  return False if $rock.left == 0;
  my $can-move = True;
  for $rock.shape.kv -> $i, $row {
    for $row.comb.kv -> $x, $c {
      next unless $c eq '#';
      if @cave[ $rock.top - $i; $rock.left + $x - 1] == 1 {
        $can-move = False;
        last;
      }
    }
  }
  $rock.left-- if $can-move;
  $can-move;
}

sub fall-rock(Rock :$rock, :@cave) {
  $frame++;
  ui.panes[1].put: "down 1 frame $frame" if $ui;
  d "down 1" unless $quiet;
  d $frame unless $quiet;
  repl if $repl-at && $frame == $repl-at;
  return False if $rock.top == 0;
  for 0..^$rock.width -> $i {
    if !defined(@cave[ $rock.height + $rock.bottom[$i] ; $rock.left + $i ]) {
      d "issue with $rock";
      show-cave(@cave);
      # stop
    }

    if $rock.top - $rock.height + $rock.bottom[$i] < 0 {
      return False;
    }

    if @cave[ $rock.top - $rock.height + $rock.bottom[$i] ; $rock.left + $i ] == 1 {
      return False;          
    }
  }
  $rock.top--;
  True;
}

sub add-rock-to-cave(Rock :$rock, :@cave) {
  repl if $repl-at && $frame == $repl-at;
  for 0 ..^ $rock.height -> \row {
    for 0 ..^ $rock.width -> \col {
      @cave[ $rock.top - $rock.height + 1 + row ; $rock.left + col ] = 1 if $rock.shape[$rock.height - row - 1].comb[col] eq '#';
    }
  }
}

sub cave-state(@cave) {
  my @depths;
  my @top;
  for @cave.reverse -> $row {
    next if $row.max == 0;
    @top.push: $row;
    # TODO tweak
    last if @top.elems == 500;
  }
  return 0 unless @top.elems > 0;
  @top.map(*.join).join
}

my @cave = ( (0) xx 7 ).Array xx 3;
my @gas-moves = $in.comb;
my $gas = 0;

my @rocks = lazy gather {
  my $i = 0;
  $*total-rocks = 0;
  loop {
    my $rock = @rock-types[$i];
    $rock.top = rocks-height(@cave) + 2 + $rock.height;
    $rock.left = 2;
    $*total-rocks++;
    d "making rock $*total-rocks and height is " ~ rocks-height(@cave) if $*total-rocks %% 100;
    last if $*total-rocks == $stop-at;
    take $rock;
    $i++;
    $i %= @rock-types.elems;
  }
  take Nil;
};

sub pad-cave(@cave,$rock) {
  if @cave.elems - 1 < $rock.top {
    @cave.append: ((0) xx 7 ).Array xx ($rock.top - @cave.elems + 1);
  }
}

my $is-new;
sub check-state(@cave,$rock,$gas) {
  my $state = cave-state(@cave) ~ "/rock/{$rock.id}/gas/$gas";
  with %states{ $state } {
    # say "repeated state $state";
    say "getting repeated states at rock $*total-rocks" if $is-new;
    $is-new = False;
  } else {
    say "getting new states: $state" unless $is-new;
    $is-new = True;
  }
  %states{ $state } = 1;
}

if (!$ui) {
  while @rocks.shift -> $rock {
    check-state(@cave,$rock,$gas);
    #d "rock " ~ ++$;
    pad-cave(@cave,$rock);
    show-cave-and-rock(@cave,$rock);
    loop {
      push-rock(@gas-moves[$gas], :$rock, :@cave);
      show-cave-and-rock(@cave,$rock);
      $gas = ($gas + 1) % @gas-moves.elems;
      fall-rock(:$rock, :@cave) or last;
      show-cave-and-rock(@cave,$rock);
    }
    add-rock-to-cave(:$rock,:@cave);
    show-cave(@cave);
  }
}

if ($ui) {
  my $current-rock;
  ui.log('ui.log');
  ui.bind: 'pane', g => 'go';
  ui.bind: 'pane', n => 'next';
  ui.panes[0].on: next => {
    if $current-rock {
      ui.panes[1].put: 'have a rock already';
    } else {
      $current-rock = @rocks.shift;
    }
    if $current-rock {
      pad-cave(@cave,$current-rock);
      ui.panes[1].put: "rock : " ~ $current-rock.raku;
    } else {
      ui.panes[1].put: "no more rocks";
    }
  }
  ui.panes[0].on: select => {
    with $current-rock -> $rock {
      ui.panes[1].put: "showing rock : " ~ $rock.raku;
      show-cave-and-rock(@cave,$rock);
    } else {
      ui.panes[1].put: 'done';
    }
  }
  ui.panes[0].on: go => {
    unless ($current-rock) {
      $current-rock = @rocks.shift;
      pad-cave(@cave,$current-rock) if $current-rock;
    }
    with $current-rock -> $rock {
      ui.panes[1].put: "doing rock";
      loop {
        push-rock(@gas-moves[$gas], :$rock, :@cave);
        # show-cave-and-rock(@cave,$rock);
        $gas = ($gas + 1) % @gas-moves.elems;
        fall-rock(:$rock, :@cave) or last;
      }
      add-rock-to-cave(:$rock,:@cave);
      $current-rock = Nil;
      show-cave-and-rock(@cave,$rock);
    } else {
      ui.panes[1].put: "no rock";
    }
  }
  ui.interact;
}

ui.shutdown;

