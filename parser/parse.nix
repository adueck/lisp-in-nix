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

  # TODO: this is not quite working with the combs.many parseElem
  # parseSExpr = combs.bindParser
  #   (combs.mapParser
  #     (x: {
  #       type = "s-expr";
  #       value = x;
  #     })
  #     (combs.thenParser
  #       (combs.parseChar "(")
  #       (combs.many parseElem)))
  #   (s: combs.mapParser (_: s) (combs.parseChar ")"));

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
  
  parseWhiteSpace = combs.many (combs.orParser [
    (combs.parseChar " ")
    (combs.parseChar "\t")
    (combs.parseChar "\n")
  ]);

in
parseElem
