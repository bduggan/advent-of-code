#!/usr/bin/env raku

unit sub MAIN($file = 'input');

class Vertex {
  has $.x;
  has $.y;
  has $.z;

  method new($x,$y,$z) { self.bless(:$x,:$y,:$z); }
  method distance-to(\v) { sqrt ($.x - v.x)² + ($.y - v.y)² + ($.z - v.z)² }
  method Str { "[$.x,$.y,$.z]" }
}

my %edges;
my @v = $file.IO.lines.map: { Vertex.new(|.split(',')) };

sub key($v1,$v2) {
  $v1 ~ ' to ' ~ $v2
}
for @v.combinations(2) -> ($v1, $v2) {
  %edges{ key($v1,$v2) } = %edges{ key($v2,$v1) } // $v1.distance-to($v2);
}

say "vertices : " ~ @v.elems;
say "edges: " ~ %edges.values.elems;
say %edges;
