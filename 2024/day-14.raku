#!/usr/bin/env raku

my $width = 101; #11;
my $height = 103; # 7;

my @bots;

for 'real'.IO.lines {
  my (\px,\py,\vx,\vy) = .comb(/'-'? \d+/);
  @bots.push: %( pos => @( px, py ), vel => @( vx, vy ) );
}

sub position-after(@p, @v, $iterations) {
  return ( @p >>+>> (@v >>*>> $iterations) ) >>%>> @($width,$height);
}

my @new = @bots.map: { position-after( .<pos>, .<vel>, 100 ) };
my $q1 = @new.grep(-> (\x,\y) { x < $width div 2 && y < $height div 2 }).elems;
my $q2 = @new.grep(-> (\x,\y) { x > $width div 2 && y < $height div 2 }).elems;
my $q3 = @new.grep(-> (\x,\y) { x < $width div 2 && y > $height div 2 }).elems;
my $q4 = @new.grep(-> (\x,\y) { x > $width div 2 && y > $height div 2 }).elems;
say [*] ($q1,$q2,$q3,$q4);

