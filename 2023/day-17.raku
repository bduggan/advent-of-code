#!/usr/bin/env raku

unit sub MAIN($file = 'input', :$max-found = 1018);  # 840 for part 1, 1017 for part 2

use Repl::Tools;
use Terminal::ANSI::OO 't';

my $in = $file.IO.slurp;
my @grid = $in.lines.map: *.comb.eager;
my \cols = @grid[0].elems;
my \rows = @grid.elems;

my %heatloss;
my %paths-to;  # to row/col
my %opposite = :l<r>, :r<l>, :u<d>, :d<u>;

class Path {
  has $.r;
  has $.c;
  has $.heat-loss = 0;
  has @.prev; # (r,c), (r,c), ...
  has @.steps = ('');
  method okay-to-go($dir) {
    return False if 1 < @.steps < 5 && @.steps.tail ne $dir;
    return False if @.steps.tail(1).join eq %opposite{ $dir };
    return False if @.steps.tail(10).join eq $dir x 10;
    return False if @.steps.tail(1) ne $dir && not @.steps < 4 || @.steps[*-4 .. *-1].unique.elems == 1; 
    return True;
  }
  method go-right {
    return Nil unless $!c < cols - 1;
    return Nil unless self.okay-to-go('r');
    my $heat-loss = $!heat-loss + @grid[$!r][$!c + 1];
    return Path.new: :$!r, :c($!c + 1), prev => ( |@.prev, ($!r, $!c) ), steps => ( |@.steps,'r'), :$heat-loss;
  }
  method go-left {
    return Nil unless $!c > 0;
    return Nil unless self.okay-to-go('l');
    my $heat-loss = $!heat-loss + @grid[$!r][$!c - 1];
    return Path.new: :$!r, :c($!c - 1), prev => ( |@.prev, ($!r, $!c) ), steps => ( |@.steps,'l' ), :$heat-loss;
  }
  method go-down {
    return Nil unless $!r < rows - 1;
    return Nil unless self.okay-to-go('d');
    my $heat-loss = $!heat-loss + @grid[$!r + 1][$!c];
    return Path.new: :r( $!r + 1), :$!c, prev => ( |@.prev, ($!r, $!c) ), steps => ( |@.steps,'d' ), :$heat-loss;
  }
  method go-up {
    return Nil unless $!r > 0;
    return Nil unless self.okay-to-go('u');
    my $heat-loss = $!heat-loss + @grid[$!r - 1][$!c];
    return Path.new: :r( $!r - 1), :$!c, prev => ( |@.prev, ($!r, $!c) ), steps => ( |@.steps,'u' ), :$heat-loss;
  }
  method at-end {
    return $!r == rows - 1 && $!c == cols - 1;
  }
  method uniq-key {
    my $last := @!steps.tail(1);
    my $key = $last;
    for @!steps.tail(10).reverse {
      once next;
      last unless $_ eq $last;
      $key ~= $last;
    }
    $key ~ "|$!r,$!c";
  }
  method uk-part1() {
    my $last := @!steps.tail;
    my $key = $last;
    for @!steps.tail(3).reverse {
      once next;
      last unless $_ eq $last;
      $key ~= $last;
    }
    $key ~ "|$!r,$!c";
  }
  method distance {
    abs( rows - $!r ) + abs( cols - $!c)
  }
  method reasonable {
    return False if self.heat-loss > $max-found;
    return False if self.heat-loss >= ($max-found + self.distance * 9);
    return True;
  }
  method sort-key {
    return [ self.heat-loss, self.distance ];
    return [ self.distance, self.heat-loss ];
    #(.heat-loss / 200) + 10 * (.distance / (rows * cols) ) }
  }
  method dump {
    my %path = self.prev.map: { .[0] ~ ',' ~ .[1]  => 'X' }
    for @grid.kv -> $r, @row {
      for @row.kv -> $c, $col {
        if ($r == self.r && $c == self.c) {
          print t.color('#99ffff') ~ t.reverse-video ~ @grid[$r][$c] ~ t.text-reset;
        } elsif %path{ "$r,$c" } {
          print t.color('#ffff99') ~ t.reverse-video ~ @grid[$r][$c] ~ t.text-reset;
        } else {
          print t.color('#666666') ~ @grid[$r][$c];
        }
      }
      say '';
    }
   }
}

my %seen;
my $min-heatloss = Inf;
my $winner;

sub fill {
 my $p = Path.new( r => 0, c => 0 );
 fail "no" if $p.go-right.go-left;
 my @perimeter = [ $p, ];
 my $round = 0;
 loop {
   #say t.clear-screen;
   say "round { $round++} : perimeter: " ~ @perimeter.elems;
   say "min distance: " ~ (min @perimeter.map: *.distance) ~ " and min heat loss is " ~ $min-heatloss.raku;
   my @n; # next
   for @perimeter -> $p {
     #$p.dump;
     #sleep 1;
     with $p.go-right { @n.push($^x) unless %seen{ $x.uniq-key } && %seen{ $x.uniq-key } < $p.heat-loss }
     with $p.go-left  { @n.push($^x) unless %seen{ $x.uniq-key } && %seen{ $x.uniq-key } < $p.heat-loss }
     with $p.go-down  { @n.push($^x) unless %seen{ $x.uniq-key } && %seen{ $x.uniq-key } < $p.heat-loss }
     with $p.go-up    { @n.push($^x) unless %seen{ $x.uniq-key } && %seen{ $x.uniq-key } < $p.heat-loss }
   };
   @perimeter = @n;
   @perimeter .= grep: { .reasonable }
   for @perimeter {
     %seen{ .uniq-key } = .heat-loss;
   }
   @perimeter = @perimeter.sort({.heat-loss}).unique( as => { .uniq-key } );
   @perimeter .= sort({ .sort-key });
   @perimeter .= head(10_000);
   last unless @perimeter.elems;
   my @ended = @perimeter.grep: *.at-end;
   next unless @ended;
   my $new = @ended.map(+*.heat-loss).min;
   if $new < $min-heatloss {
     $min-heatloss = $new;
     $winner = @ended.first(*.heat-loss == $min-heatloss);
   }
   for @ended -> $e {
    say '----> heatloss: ' ~ $e.heat-loss;
    #say '----> path : ' ~ $e.prev.raku;
    #$e.dump;
    #say $e;
   }
 }
}

fill;

say "min heatloss is " ~ $min-heatloss;
with $winner {
  say "winner:";
  #.dump;
  say "heatloss is : " ~ .heat-loss;
}

