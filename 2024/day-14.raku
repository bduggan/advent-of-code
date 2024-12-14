#!/usr/bin/env raku

use Terminal::ANSI;

unit sub MAIN($start, $delay);

my $width = 101;
my $height =  103;

my @bots;

for 'real'.IO.lines {
  my (\px,\py,\vx,\vy) = .comb(/'-'? \d+/);
  @bots.push: %( pos => @( px, py ), vel => @( vx, vy ) );
}

sub position-after(@p, @v, $iterations) {
  return ( @p »+» (@v »*» $iterations) ) »%» @($width,$height);
}

sub part-one {
  my @new = @bots.map: { position-after( .<pos>, .<vel>, 100 ) };
  my $q1 = @new.grep(-> (\x,\y) { x < $width div 2 && y < $height div 2 }).elems;
  my $q2 = @new.grep(-> (\x,\y) { x > $width div 2 && y < $height div 2 }).elems;
  my $q3 = @new.grep(-> (\x,\y) { x < $width div 2 && y > $height div 2 }).elems;
  my $q4 = @new.grep(-> (\x,\y) { x > $width div 2 && y > $height div 2 }).elems;
  say [*] ($q1,$q2,$q3,$q4);
}

sub display(@new, $i, $label = "") {
    my %counts;
    %counts{ .Str }++ for @new;
    move-to(0,0);
    for 0 ..^ $width -> \y {
      for 0 ..^ $height -> \x {
        print %counts{ [x,y].Str } ?? '█' !! ' ';
      }
      print "\n";
    }
    say "-" x ($width div 2 - 4) ~ "  $i   " ~ ("-" x ($width div 2 - 4) );
}

sub part-two {
  my $output = open "output.txt", :w;
  my $i = $start;
  loop {
    my @new = @bots.map: { position-after( .<pos>, .<vel>, $i ) };
    my %counts;
    %counts{ .Str }++ for @new;
    display(@new,$i);
    sleep $delay with $delay;
    ++$i;
  }
}

part-two;