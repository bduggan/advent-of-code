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

# $in = 'day-09.input'.IO.slurp;

my @seen;

my $size = 5;
my @heads = { :row(0), :col(0) } xx 1;
my %tail = :row(0), :col(0);
@seen[0;0] = 1;

sub move-head(%head, :$dir) {
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
sub move-tail(%head) {
  if (%head<col> - %tail<col>).abs <= 1 && (%head<row> - %tail<row>).abs <= 1 {
    #say 'touching.';
    return;
  }
  #say "moving tail";
  %tail<col> -= (%tail<col> <=> %head<col>).Int;
  %tail<row> -= (%tail<row> <=> %head<row>).Int;
  @seen[ %tail<row> ; %tail<col> ] = 1;
  #say "tail is now " ~ %tail.raku;
}

sub draw($caption = Nil) {
  say "$caption:" if $caption;
  for 0..$size X 0..$size -> (\x, \col) {
    my \row = $size - x;
		my $printed = False;
    for @heads.kv -> $i, %head {
      if %head<row> == row && %head<col> == col {
        print $i + 1;
				$printed = True;
      }
    }
    next if $printed;
    if %tail<row> == row && %tail<col> == col {
      print 'T';
    } elsif @seen[ row; col ] {
      print '#';
    } else {
      print '.';
    }
    print "\n" if col==5;
  }
  prompt '>';
}

draw('start');

for $in.lines {
  say "line is $_";
  my ($dir,$n) = .split(' ');
  for 0..^$n {
    draw;
    move-head(@heads[0],:$dir);
    draw;
    move-tail($_) for @heads;
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
