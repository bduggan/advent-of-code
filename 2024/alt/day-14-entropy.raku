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

sub display(@new, $i, $label = "", Bool :$get-entropy	) {
    my %counts;
    %counts{ .Str }++ for @new;
    
    # Calculate local entropy using 3x3 neighborhoods
    my $total_entropy = 0;
    
    for 1 ..^ ($height - 1) -> \y {
        for 1 ..^ ($width - 1) -> \x {
            # Count ones in 3x3 neighborhood
            my $neighborhood_ones = 0;
            for (-1..1) -> \dy {
                for (-1..1) -> \dx {
                    $neighborhood_ones += %counts{ [x+dx,y+dy].Str } ?? 1 !! 0;
                }
            }
            
            # Calculate local probabilities (out of 9 cells)
            my $p1 = $neighborhood_ones / 9;
            my $p0 = (9 - $neighborhood_ones) / 9;
            
            # Add to total entropy
            my $local_entropy = 0;
            if $p1 > 0 { $local_entropy -= $p1 * log($p1) / log(2) }
            if $p0 > 0 { $local_entropy -= $p0 * log($p0) / log(2) }
            $total_entropy += $local_entropy;
        }
    }
    
    # Average the entropy over all neighborhoods
    my $avg_entropy = $total_entropy / (($height-2) * ($width-2));
    
    return $avg_entropy if $get-entropy;
    # Display grid
    move-to(0,0);
    for 0 ..^ $height -> \y {
        for 0 ..^ $width -> \x {
            print %counts{ [x,y].Str } ?? '█' !! ' ';
        }
        print "\n";
    }
    
    say "-" x ($width div 2 - 15) ~ 
        "  Gen: $i   Entropy: {$avg_entropy.fmt('%.3f')}  " ~ 
        ("-" x ($width div 2 - 15));
}

sub part-two {
  my $output = open "output.txt", :w;
  my $i = $start;
  my $min-entropy = Inf;
  loop {
    my @new = @bots.map: { position-after( .<pos>, .<vel>, $i ) };
    my %counts;
    %counts{ .Str }++ for @new;
    my $entropy = display(@new,$i, :get-entropy);
    if $entropy < $min-entropy {
      #display(@new,$i);
      $min-entropy = $entropy;
      say "found min-entropy at $i: $min-entropy";
      #sleep $delay with $delay;
    }
    ++$i;
  }
}

part-one;
part-two;
