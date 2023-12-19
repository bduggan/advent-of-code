#!/usr/bin/env raku

my ($code,$input) = 'input'.IO.slurp.split("\n\n");
grammar Gear {
  rule TOP {
     <label> '{' [ <expr>+ % ',' ] '}'
  }
  rule label { \w+ }
  rule var { \w+ }
  rule num { \d+ }
  rule fallback { <label> }
  rule op { '<' | '>' }
  rule cond { <var> <op> <num> }
  rule expr { [ <cond> ':' <label> ] | <fallback> }
}

class Actions {
  method TOP($/) {
    my @out = "\nsub " ~ "$<label>".uc ~ ' {';
    for $<expr><> {
      @out.push: .made
    }
    @out.push: '}';
    $/.make: @out.join("\n");
  }
  method expr($/) {
    with $<cond> -> $cond {
      $/.make: "  if { $cond.made } \{ goto { '&' ~ $<label>.uc } \};";
    } else {
      $/.make: "  goto { '&' ~ $<fallback>.uc };";
    }
  }
  method cond($/) {
    $/.make: "( \$" ~ $/ ~ " )";
  }
}

my @prog;
for $code.lines {
  my $actions = Actions.new;
  my $tree = Gear.parse($_, :$actions) or die "no match";
  @prog.push: $tree.made;
}
@prog.push: "";
@prog.push: 'sub A { print("accepted\\n"); }';
@prog.push: 'sub R { print("rejected\\n"); }';

my $sum;
for $input.lines -> $i is copy {
  $i .= subst('{','my $');
  $i .= subst('}',';');
  $i .= subst(',','; my $', :g);
  "runme.pl".IO.spurt: ($i, |@prog.lines, "IN()").join("\n");
  my $status = qx[perl runme.pl];
  if $status.trim eq 'accepted' {
    say "accepted $i";
    $sum += $i.comb(/\d+/).sum;
  }
}

say "sum $sum";
