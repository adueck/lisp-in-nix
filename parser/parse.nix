let
  combinators = import ./combinators.nix;
  parseNumber = import ./parse-number.nix;

  parseElem = tokens: let
    res = parseElem' (eatWhiteSpace tokens);
  in if res == false
    then false
    else {
      tokens = eatWhiteSpace res.tokens;
      body = res.body;
    };

  parseElem' = combinators.orParser [
    parseSExpr
    parseOp
    parseNumber
  ];
 
  parseSExpr = tokens: let
    first = builtins.head tokens;
    rest = builtins.tail tokens;
  in if first == "("
    then let
      args = parseSExpr' [ ] rest;
    in if args == false
      then false
      else {
        tokens = args.tokens;
        body = {
          type = "s-expr";
          value = args.body; 
        };
      }
    else false;

  eatWhiteSpace = tokens: if (builtins.length tokens) == 0
    then tokens
    else let
      first = builtins.head tokens;
    in if isWhiteSpace first
      then eatWhiteSpace (builtins.tail tokens)
      else tokens;

  parseSExpr' = prev: tokens: let 
    first = builtins.head tokens;
    rest = builtins.tail tokens;
  in if first == ")" then {
    tokens = rest;
    body = prev;
  } else let
    nextArg = parseElem tokens;
  in if nextArg == false
    then false
    else parseSExpr'
      (builtins.concatLists [ prev [nextArg.body] ])
      nextArg.tokens;

  parseOp = tokens: let
    first = builtins.head tokens;
    rest = builtins.tail tokens;
    val = if first == "+"
      then "+"
      else if first == "-"
      then "-"
      else if first == "*"
      then "*"
      else false;
    in if val == false
      then val
      else { tokens = rest; body = { type = "op"; value = val; }; };
  
  isWhiteSpace = s: s == " " || s == "\t" || s == "\n";  
in
parseElem
