#!/usr/bin/env raku

# see day-10-part-1 for turning the input into a path
# with box drawing characters

my regex looptop { '┌' '─'* '┐' }
my regex loopbot { '└' '─'* '┘' }
my regex vert    { '└' '─'* '┐' | '┌' '─'* '┘' | '│' }

say sum 'path'.IO.lines.map: {
  m/:s ^^ [ <looptop> | <loopbot> | <vert> ]* $$/ or die "bad line '$_'";
  sum $<vert>.map: {
          .comb[$^begin.from .. $^end.from]
          .grep( * eq ' ')
       }
}
