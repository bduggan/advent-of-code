#!/usr/bin/env raku

unit sub MAIN($file = 'input');

class Vertex {
  has $.x;
  has $.y;
  has $.z;

  method new($x,$y,$z) { self.bless(:$x,:$y,:$z); }
  method distance-to(\v) { sqrt ($.x - v.x)² + ($.y - v.y)² + ($.z - v.z)² }
  method Str { "node_{$.x}_{$.y}_{$.z}" }
}

my %edges;
my @v = $file.IO.lines.map: { Vertex.new(|.split(',')) };

sub key($v1,$v2) {
  [ $v1, $v2 ].sort.join(' -- ');
}

for @v.combinations(2) -> ($v1, $v2) {
  %edges{ key($v1,$v2) } //= $v1.distance-to($v2);
}

say "vertices : " ~ @v.elems;
say "edges: " ~ %edges.values.elems;

my %connected;

my $start = @v.head;
my $closest = %edges.keys.min( by => { %edges{$_} });

say "connection 0 is $closest";

%connected{$closest} = True;
%edges{ $closest }:delete;
while %edges.keys > 0 {
  my $next = %edges.keys.min( by => { %edges{$_} });
  note "connection " ~ ++$ ~ " is $next";
  %connected{ $next } = True;
  %edges{ $next }:delete;
  last if ++$ > 9;
}

my @rows;
for %connected.keys -> $c {
  @rows.push: $c;
}

"graph.out".IO.spurt: [ 'graph G { ', @rows, '} ' ].join("\n");
shell "ccomps graph.out";
