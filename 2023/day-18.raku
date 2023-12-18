#!/usr/bin/env raku

unit sub MAIN($file = 'input');

my regex dir { L|R|U|D }
my regex count { \d+ }
my regex color { '(#' \w+ ')' }

my @grid;
my @pos = 1000, 1000;

my %dirs = U => <-1 0>, D => <1 0>, L => <0 -1>, R => <0 1>;

for $file.IO.lines {
  m/:s <dir> <count> <color>/ or die "no match $_";
  my @v := %dirs{ $<dir> } »*» +$<count>  or die "bad dir";  
  my @rows = @pos[0] ...^ (@pos[0] + @v[0]);
  my @cols = @pos[1] ...^ (@pos[1] + @v[1]);
  @rows = @pos[0] unless @rows;
  @cols = @pos[1] unless @cols;
  for @rows -> $r {
    for @cols -> $c {
      @grid[ $r ] //= [];
      @grid[ $r ][ $c ] = '#'
    }
  }
  @pos »+=» @v;
}

my @strings;
for @grid -> $r {
  next unless $r;
  my $str = '';
  for @$r {
    $str ~= $_ // '.';
  }
  @strings.push: $str;
}

say @strings.join("\n");

