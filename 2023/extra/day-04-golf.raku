say sum lines.map: {
   .split(':')[1].split('|') andthen (
   2 ** (((bag .[0].words) ∩ bag .[1].words)
-1)).Int
}
