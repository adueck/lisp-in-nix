let
  combs = import ./combinators.nix;
  parseNumber = import ./parse-number.nix;

  parseElem = combs.bindParser
    (combs.thenParser parseWhiteSpace parseElemContent)
    # TODO: BETTER ABSTRACTION FOR THESE TWO A
    (val:
      combs.mapParser
      (_: val)
      parseWhiteSpace);

  parseElemContent = combs.alternative [
    parseSExpr
    parseOp
    parseNumber
  ];
  
  parseSExpr = (combs.bindParser
    (combs.thenParser     
      (combs.parseChar "(")
      (combs.many parseElem))
    # TODO: BETTER ABSTRACTION FOR THESE TWO B
    (val: combs.mapParser
      (_: { type = "s-expr"; value = val; })
      (combs.parseChar ")")));
  
  parseOp = combs.mapParser
    (x: {
      type = "op";
      value = x;
    })
    (combs.alternative [
      (combs.parseChar "+")
      (combs.parseChar "-")
      (combs.parseChar "*")
    ]);
  
  parseWhiteSpace = combs.many (combs.alternative [
    (combs.parseChar " ")
    (combs.parseChar "\t")
    (combs.parseChar "\n")
  ]);

in
parseElem
