#!/usr/bin/env raku

unit sub MAIN($file = 'input');
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
  method go-right {
    return Nil unless $.c < cols - 1;
    return Nil if @.steps.tail(3).join eq 'rrr';
    return Nil if @.steps.tail(1).join eq 'l';
    my $heat-loss = $!heat-loss + @grid[$.r][$.c + 1];
    return Path.new: :$.r, :c($.c + 1), prev => ( |@.prev, ($.r, $.c) ), steps => ( |@.steps,'r'), :$heat-loss;
  }
  method go-left {
    return Nil unless $.c > 0;
    return Nil if @.steps.tail(3).join eq 'lll';
    return Nil if @.steps.tail(1).join eq 'r';
    my $heat-loss = $!heat-loss + @grid[$.r][$.c - 1];
    return Path.new: :$.r, :c($.c - 1), prev => ( |@.prev, ($.r, $.c) ), steps => ( |@.steps,'l' ), :$heat-loss;
  }
  method go-down {
    return Nil unless $.r < rows - 1;
    return Nil if @.steps.tail(3).join eq 'ddd';
    return Nil if @.steps.tail(1).join eq 'u';
    my $heat-loss = $!heat-loss + @grid[$.r + 1][$.c];
    return Path.new: :r( $.r + 1), :$.c, prev => ( |@.prev, ($.r, $.c) ), steps => ( |@.steps,'d' ), :$heat-loss;
  }
  method go-up {
    return Nil unless $.r > 0;
    return Nil if @.steps.tail(3).join eq 'uuu';
    return Nil if @.steps.tail(1).join eq 'd';
    my $heat-loss = $!heat-loss + @grid[$.r - 1][$.c];
    return Path.new: :r( $.r - 1), :$.c, prev => ( |@.prev, ($.r, $.c) ), steps => ( |@.steps,'u' ), :$heat-loss;
  }
  method at {
    return '#' unless 0 <= $.c < cols;
    return '#' unless 0 <= $.r < rows;
    @grid[$.r][$.c]
  }
  #method heat-loss {
  #  (sum @.prev.map: -> ($r, $c) { @grid[$r][$c] }) - @grid[0][0] + @grid[$.r][$.c]
  #}
  method at-end {
    return $.r == rows - 1 && $.c == cols - 1;
  }
  method uniq-key {
    @.steps.tail(3).join ~ "|$.r,$.c";
    #return "$.r,$.c";
  }
  method distance {
    abs( rows - $.r ) + abs( cols - $.c)
  }
  method reasonable {
    return True;
    my $max-found = 120; #108;
    #my $max-found = 1100; # found 1190; 1100 is too high too
    return False if self.heat-loss > $max-found;
    return False if self.heat-loss >= ($max-found - self.distance);
    return True;
  }
  method sort-key {
    return self.distance; #, self.heat-loss ];
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
 my @perimeter = [ $p, ];
 my $round = 0;
 loop {
   say "round { $round++} : perimeter: " ~ @perimeter.elems;
   say "min distance: " ~ min @perimeter.map: *.distance;
   say "seen : " ~ %seen.keys.elems;
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
   #@perimeter .= sort({ .sort-key });
   #@perimeter .= head(1000);
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
    say $e;
   }
 }
}

fill;

say "min heatloss is " ~ $min-heatloss;
