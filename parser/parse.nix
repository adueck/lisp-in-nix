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
    (value: {
      type = "op";
      inherit value;
    })
    (combs.alternative [
      (combs.char "+")
      (combs.char "-")
      (combs.char "*")
      (combs.successive [
        (combs.char "l")
        (combs.char "e")
        (combs.char "t")
      ])
    ]);

  # TODO
  # parseIdentifier = ...
  #   use < > comparisons to check if chars are in range a-z

  parseWhiteSpace = combs.many (combs.alternative [
    (combs.char " ")
    (combs.char "\t")
    (combs.char "\n")
    parseComment
  ]);

  parseComment = combs.alternative [
    (combs.everythingBetween
      (combs.char ";") (combs.char "\n"))
    (combs.everythingBetween
      (combs.successive [(combs.char "#") (combs.char "|")])
      (combs.successive [(combs.char "|") (combs.char "#")]))
  ];

in
parseElem
