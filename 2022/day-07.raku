#!/usr/bin/env raku

my $in = q:to/IN/;
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
IN

# $in = 'day-07.input'.IO.slurp;

my @cwd = '/';
my %totals;

my regex dir { <[a..z]>+ }
my regex size { <[0..9]>+ }
my regex filename { \w+ }

for $in.lines {
  when /:s '$' cd '/'    / { @cwd = ('/')          }
  when /:s '$' cd <dir>  / { @cwd.push("$<dir>/") }
  when /:s '$' cd '..'   / { @cwd.pop             }
  when /:s <size> <filename>/ {
    %totals{ [\~] @cwd } »+=» $<size> xx *
  }
}

# part 1
say %totals.values.grep( * <= 100000).sum;

# part 2
my $total-space = 70000000;
my $unused = $total-space - %totals{ '/' };
my $need = 30000000;

my %choices = %totals.grep: { $unused + .value > $need }
say %choices.values.min;
