#!/usr/bin/env raku

my $in = q:to/X/;
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
X

$in = 'input'.IO.slurp;

my regex id { \d+ }
my regex count { \d+ }
my regex color { red | green | blue }
my regex cubes { :s <count> <color> }
my regex result { :s <cubes>+ % ',' }

my %max = :12red, :13green, :14blue;
my @valid;
my $power-sum = 0;
LINE:
for $in.lines {
  m/:s Game <id> ':' [ <result>+ % ';' ] $/ or die "bad line $_";
  my $power = compute-power($/);
  $power-sum += $power;
  for $<result> -> $r {
    for $r<cubes> -> $c {
      if $c<count> > %max{ $c<color> } {
        say "too many $c<color> cubes in game $<id>";
        next LINE;
      }
    }
  }
  @valid.push: +$<id>;
}

sub compute-power($r) {
  my %maxes;
  for $r<result> -> $r {
    for $r<cubes> -> $c {
      %maxes{ $c<color> } //= +$c<count>;
      %maxes{ $c<color> } max= +$c<count>;
    }
  }
  return [*] %maxes.values;
}

# part 1
say "sum: " ~ @valid.sum;

# part 2
say "power sum: " ~ $power-sum;
