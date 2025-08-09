let
  combs = import ./combinators.nix;
  parseNumber = import ./parse-number.nix;
  utils = import ../utils/utils.nix;

  parseElem = combs.between
    parseWhiteSpace parseWhiteSpace
    parseElemContent;

  parseElemContent = combs.alternative [
    parseSExpr
    parseOp
    parseIdentifier
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
      (combs.parseStr "let")
    ]);

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
      (combs.parseStr "#|")
      (combs.parseStr "|#"))
  ];

  parseIdentifier = combs.mapParser
    (value: {
      type = "identifier";
      value = combineChars value;
    })
    (combs.headAndRest
      (combs.charRange "A" "z")
      (combs.alternative [
        (combs.charRange "0" "z")
        (combs.char "-")
        (combs.char "_")
      ]));

  combineChars = xs: if (builtins.length xs == 0)
    then ""
    else let
      inherit (utils.getHead xs) first rest;
    in first + (combineChars rest);

in
parseElem
