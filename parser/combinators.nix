let
  orParser = parsers: tokens:
    if (builtins.length tokens == 0) || (builtins.length parsers) == 0
      then false
      else let
        first = builtins.head parsers;
        rest = builtins.tail parsers;
        result = first tokens;
      in
        if result == false
          then orParser rest tokens
          else result;
  thenParser = parser: f: tokens:
    let
      res = parser tokens;
    in if res == false
      then false
      else f res.tokens;
in
{ orParser = orParser; thenParser = thenParser; }
