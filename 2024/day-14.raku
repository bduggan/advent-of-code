#!/usr/bin/env raku

use Terminal::ANSI;

unit sub MAIN($start = 1, $delay = Nil);

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
  my (\w, \h) = ( $width, $height) »div» 2;
  say [*] @new.grep(-> (\x,\y) { x < w && y < h }),
          @new.grep(-> (\x,\y) { x > w && y < h }),
          @new.grep(-> (\x,\y) { x < w && y > h }),
          @new.grep(-> (\x,\y) { x > w && y > h })
}

sub display(@new, $i, $label = "") {
    my %counts;
    %counts{ .Str }++ for @new;
    move-to(0,0);
    for 0 ..^ $height -> \y {
      for 0 ..^ $width -> \x {
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

part-one;
part-two;
