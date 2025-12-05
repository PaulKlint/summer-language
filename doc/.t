.{{
# tuples -- count frequency of word pairs and triples #

const letter :=
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
      interesting := 3;

proc combine(a, b)
  return(a || '/' || b);

proc word(data)
( break(letter) & return(span(letter))
);

program tuples(file_names)
( var f, tuple, tupletab := table(1000, 0);

  for f in file_names
  do var data;
     if data := file(f,'r') fails then
        put('Can''t open ', f, '\n')
     else
        scan data
        for var w1 , w2 := word(data), w3 := word(data),
                pair, triple;
            while [w1, w2, w3] := [w2, w3, word(data)]
            do pair := combine(w1, w2);
               tupletab[pair] := tupletab[pair] + 1;
               triple := combine(pair, w3);
               tupletab[triple] := tupletab[triple] + 1;
            od;
            pair := combine(w2, w3);    # the last pair #
            tupletab[pair] := tupletab[pair] + 1
        rof;
        data.close 
     fi
  od;
  for tuple in tupletab.index 
  do var freq := tupletab[tuple];
     if freq > interesting then
        put(tuple.left(20,' '),string(freq).right(10,' '),'\n')
     fi
  od
)
.}}
