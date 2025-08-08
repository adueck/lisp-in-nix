let
  combs = import ./combinators.nix;
  parseNumber = import ./parse-number.nix;

  # TODO: to simplify this we need a bindParser combinator
  parseElem = combs.thenParser parseWhiteSpace (tokens: let
    res = parseElem' tokens;
  in if res == false
    then false
    else {
      tokens = (parseWhiteSpace res.tokens).tokens;
      body = res.body;
    });

  parseElem' = combs.orParser [
    parseSExpr
    parseOp
    parseNumber
  ];
 
  parseSExpr = combs.mapParser
    (x: {
      type = "s-expr";
      value = x;
    })
    (combs.thenParser
      (combs.parseChar "(")
      (parseSExpr' [ ]));

  parseWhiteSpace = tokens: if (builtins.length tokens) == 0
    then { body = true; tokens = tokens; }
    else let
      first = builtins.head tokens;
    in if isWhiteSpace first
      then parseWhiteSpace (builtins.tail tokens)
      else { body = true; tokens = tokens; };

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

  parseOp = combs.mapParser
    (x: {
      type = "op";
      value = x;
    })
    (combs.orParser [
      (combs.parseChar "+")
      (combs.parseChar "-")
      (combs.parseChar "*")
    ]);
  
  isWhiteSpace = s: s == " " || s == "\t" || s == "\n";  
in
parseElem
