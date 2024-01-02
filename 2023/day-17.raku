#!/usr/bin/env raku

use lib $*HOME.child('raku-elapsed/lib');
unit sub MAIN($file = 'input', :$max-found = 840);

use Elapsed;
use Repl::Tools;
use Terminal::ANSI::OO 't';

my $in = $file.IO.slurp;
my @grid = $in.lines.map: *.comb.eager;
my \cols = @grid[0].elems;
my \rows = @grid.elems;

my %heatloss;
my %paths-to;  # to row/col

class Path {
  has $.r;
  has $.c;
  has $.heat-loss = 0;
  has @.prev; # (r,c), (r,c), ...
  has @.steps = ('');
  method okay-to-go($dir) {
    return False if @.steps.tail(10).join eq $dir x 10;
    return True if @.steps.tail(3 | 2 | 1).unique eq $dir;
    return True if @.steps.tail(4).unique ne $dir;
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
    return self.heat-loss;
    return [ self.distance, self.heat-loss ];
    #(.heat-loss / 200) + 10 * (.distance / (rows * cols) ) }
  }
  method dump {
    my %path = self.prev.map: { .[0] ~ ',' ~ .[1]  => 'X' }
    for @grid.kv -> $r, @row {
      for @row.kv -> $c, $col {
        if ($r == self.r && $c == self.c) {
          print t.color('#ddddff') ~ t.reverse-video ~ @grid[$r][$c] ~ t.text-reset;
        } elsif %path{ "$r,$c" } {
          print t.reverse-video ~ @grid[$r][$c] ~ t.text-reset;
        } else {
          print @grid[$r][$c];
        }
      }
      say '';
    }
   }
}

my %seen;
my $min-heatloss = Inf;

sub fill {
 my $p = Path.new( r => 0, c => 0 );
 say $p.go-right.go-left;
 my @perimeter = [ $p, ];
 my $round = 0;
 loop {
   say "round { $round++} : perimeter: " ~ @perimeter.elems;
   say "min distance: " ~ (min @perimeter.map: *.distance) ~ " and min heat loss is " ~ $min-heatloss.raku;
   my @n; # next
   for @perimeter -> $p {
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
   }
   for @ended -> $e {
    say '----> heatloss: ' ~ $e.heat-loss;
    #say '----> path : ' ~ $e.prev.raku;
    $e.dump;
    #say $e;
   }
 }
}

fill;

say "min heatloss is " ~ $min-heatloss;
