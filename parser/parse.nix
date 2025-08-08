let
  combs = import ./combinators.nix;
  parseNumber = import ./parse-number.nix;

  parseElem = combs.bindParser
    (combs.thenParser parseWhiteSpace parseElem')
    (elem: combs.mapParser (_: elem) parseWhiteSpace);

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

  parseSExpr' = prev: tokens: if (builtins.length tokens) == 0
    then false
    else let 
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
  
  parseWhiteSpace = tokens: if (builtins.length tokens) == 0
    then { body = true; tokens = tokens; }
    else let
      first = builtins.head tokens;
    in if isWhiteSpace first
      then parseWhiteSpace (builtins.tail tokens)
      else { body = true; tokens = tokens; };
  
  isWhiteSpace = s: s == " " || s == "\t" || s == "\n";  
in
parseElem
