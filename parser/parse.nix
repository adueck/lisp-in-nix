let
  combs = import ./combinators.nix;
  parseNumber = import ./parse-number.nix;

  parseElem = combs.between
    parseWhiteSpace parseWhiteSpace
    parseElemContent;

  parseElemContent = combs.alternative [
    parseSExpr
    parseOp
    parseNumber
  ];
  
  parseSExpr = combs.mapParser
    (value: { type = "s-expr"; inherit value; })
    (combs.between
      (combs.char "(") (combs.char ")")
      (combs.many parseElem));
  
  parseOp = combs.mapParser
    (x: {
      type = "op";
      value = x;
    })
    (combs.alternative [
      (combs.char "+")
      (combs.char "-")
      (combs.char "*")
    ]);
  
  parseWhiteSpace = combs.many (combs.alternative [
    (combs.char " ")
    (combs.char "\t")
    (combs.char "\n")
    (combs.char "eof")
  ]);

in
parseElem
