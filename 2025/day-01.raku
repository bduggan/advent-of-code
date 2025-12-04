#!/usr/bin/env raku

unit sub MAIN($file = 'input');

my $at = 50;
<<<<<<< Updated upstream
my $zeroes = 0;

for $file.IO.lines {
  my $num = +.comb(/\d+/).join;
  my $dir = .comb(/L|R/);
  $num *= -1 if $dir eq 'L';
  $at += $num;
  $at %= 100;
  $zeroes++ if $at == 0;
}

say "zero count: $zeroes";
=======
my $passes = 0;
my $zeroes = 0;
say " - The dial starts by pointing at $at";
for 'input-01.real'.IO.lines {
  my $these-passes = 0;
  my $num = +.comb(/\d+/).join;
  my $dir = .comb(/L|R/);
  if $dir eq 'R' {
    #say "at $at going $_ (passes: $passes) will end at {$at + $num}";
    $at += $num;
    $these-passes = $at div 100;
    $these-passes -= 1 if $at == 100;
    $at %= 100;
  }
  if $dir eq 'L' {
    $at -= $num;
    $these-passes = 1 + (-$at) div 100;
    $these-passes -= 1 if $at == 0;
    $at %= 100;
  }
  print "- The dial is rotated $_ to point at $at.";
  print "  During this rotation it points at 0 $these-passes times" if $these-passes > 0;
  print "\n";
  $passes += $these-passes;
  $passes++ if $at == 0;
}

say "passes count: $passes";
>>>>>>> Stashed changes
