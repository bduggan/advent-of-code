#!/usr/bin/env raku

my $in = q:to/IN/;
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
IN

$in = 'day-09.input'.IO.slurp;

my @seen;

my %head = :row<100>, :col<100>;
my %tail = :row<100>, :col<100>;
@seen[100;100] = 1;

sub move-head(:$dir) {
  # say "moving head $dir";
  # move the head 1 unit in a direction
  given $dir {
    when 'L'  { %head<col>--; }
    when 'R'  { %head<col>++ }
    when 'U'  { %head<row>++; }
    when 'D'  { %head<row>--; }
  }
  # say "head is now " ~ %head.raku;
}

# make one move to get tail closer to head.
sub move-tail {
  if (%head<col> - %tail<col>).abs <= 1 && (%head<row> - %tail<row>).abs <= 1 {
    #say 'touching.';
    return;
  }
  #say "moving tail";
  my $diff = %head<row col> >>->> %tail<row col>;
  if %head<row> == %tail<row> and %head<col> == %tail<col> {
    say "no move: same place";
  } elsif %head<row> == %tail<row> {
    %tail<col> += (%tail<col> > %head<col> ?? -1 !! 1)
  } elsif %head<col> == %tail<col> {
    %tail<row> += (%tail<row> < %head<row> ?? 1 !! -1)
  } else {
    %tail<col> += (%tail<col> > %head<col> ?? -1 !! 1);
    %tail<row> += (%tail<row> < %head<row> ?? 1 !! -1)
  }
  @seen[ %tail<row> ; %tail<col> ] = 1;
  #say "tail is now " ~ %tail.raku;
}

sub draw {
  return;
  for 0..10 X 0..10 -> (\x, \col) {
    my \row = 5 - x;
    if %head<row> == row && %head<col> == col {
      print 'H';
    } elsif %tail<row> == row && %tail<col> == col {
      print 'T';
    } elsif @seen[ row; col ] {
      print '#';
    } else {
      print '.';
    }
    print "\n" if col==5;
  }
}

for $in.lines {
  say "line is $_";
  my ($dir,$n) = .split(' ');
  for 0..^$n {
    draw;
    move-head(:$dir);
    draw;
    move-tail;
  }
}

draw;

my $total = 0;
for @seen -> $row {
  next unless $row;
  my @row = @$row;
  my $these = @row.grep({.defined && $_ == 1}).elems;
  $total += $these;
}

say $total;
