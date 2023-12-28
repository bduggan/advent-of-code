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
  has @.prev; # (r,c), (r,c), ...
  has @.steps = ('');
  method go-right {
    return Nil unless $.c < cols - 1;
    return Nil if @.steps.tail(3).join eq 'rrr';
    return Nil if @.steps.tail(1).join eq 'l';
    return Path.new: :$.r, :c($.c + 1), prev => ( |@.prev, ($.r, $.c) ), steps => ( |@.steps,'r');
  }
  method go-left {
    return Nil unless $.c > 0;
    return Nil if @.steps.tail(3).join eq 'lll';
    return Nil if @.steps.tail(1).join eq 'r';
    return Path.new: :$.r, :c($.c - 1), prev => ( |@.prev, ($.r, $.c) ), steps => ( |@.steps,'l' );
  }
  method go-down {
    return Nil unless $.r < rows - 1;
    return Nil if @.steps.tail(3).join eq 'ddd';
    return Nil if @.steps.tail(1).join eq 'u';
    return Path.new: :r( $.r + 1), :$.c, prev => ( |@.prev, ($.r, $.c) ), steps => ( |@.steps,'d' );
  }
  method go-up {
    return Nil unless $.r > 0;
    return Nil if @.steps.tail(3).join eq 'uuu';
    return Nil if @.steps.tail(1).join eq 'd';
    return Path.new: :r( $.r - 1), :$.c, prev => ( |@.prev, ($.r, $.c) ), steps => ( |@.steps,'u' );
  }
  method at {
    return '#' unless 0 <= $.c < cols;
    return '#' unless 0 <= $.r < rows;
    @grid[$.r][$.c]
  }
  method heat-loss {
    (sum @.prev.map: -> ($r, $c) { @grid[$r][$c] }) - @grid[0][0] + @grid[$.r][$.c]
  }
  method at-end {
    return $.r == rows - 1 && $.c == cols - 1;
  }
  method uniq-key {
    #@.steps.tail(3).join ~ "|$.r,$.c";
    "$.r,$.c";
  }
  method distance {
    abs( rows - $.r ) + abs( cols - $.c)
  }
  method reasonable {
    my $max-found = 120; #108;
    return False if self.heat-loss > $max-found;
    #return False if self.heat-loss >= ($max-found - self.distance);
    return True;
  }
  method sort-key {
    self.heat-loss
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

my $p = Path.new( r => 0, c => 0 );
my $q = $p.go-right.go-right.go-down.go-right.go-right.go-right.go-up.go-right.go-right.go-right;
say $q.go-down.go-down.go-right.go-right.go-down.go-down.go-right.go-down.go-down.go-down.go-right.go-down.go-down.go-down.go-left.go-down.go-down.go-right.heat-loss;
#for 1..10 {
#  $p = $p.go-right or last;
#  say "iteration $_, we are at " ~ $p.at;
#}

my %seen;
my $min-heatloss = Inf;

sub fill {
 my $p = Path.new( r => 0, c => 0 );
 my @perimeter = [ $p, ];
 loop {
   say "--- perimeter: " ~ @perimeter.elems;
   say "min distance: " ~ min @perimeter.map: *.distance;
   say "seen : " ~ %seen.keys.elems;
   my @n; # next
   for @perimeter -> $p {
     with $p.go-right { @n.push: $^x }
     with $p.go-left  { @n.push: $^x }
     with $p.go-down  { @n.push: $^x }
     with $p.go-up    { @n.push: $^x }
   };
   @perimeter = @n;
   @perimeter = @perimeter.grep: { .reasonable }
   @perimeter = @perimeter.sort({ .sort-key }).head(1000);
   @perimeter = @perimeter.grep: {
     !%seen{ .uniq-key } || ( %seen{ .uniq-key } > .heat-loss )
   };
   for @perimeter {
     %seen{ .uniq-key } = .heat-loss;
   }
   last unless @perimeter.elems;
   my @ended = @perimeter.grep: *.at-end;
   next unless @ended;
   my $new = @ended.map(+*.heat-loss).min;
   if $new < $min-heatloss {
     $min-heatloss = $new;
   }
   for @ended -> $e {
    say '----> heatloss: ' ~ $e.heat-loss;
    say '----> path : ' ~ $e.prev.raku;
    #$e.dump;
   }
 }
}

fill;

say "min heatloss is " ~ $min-heatloss;
