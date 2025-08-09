let
  combs = import ./combinators.nix;
  parseNumber = import ./parse-number.nix;
  utils = import ../utils/utils.nix;

  label = type: value: {
    inherit type value;
  };

  parseElem = combs.between
    parseWhiteSpace parseWhiteSpace
    parseElemContent;

  parseElemContent = combs.alternative [
    parseSExpr
    parseOp
    parseBoolean
    parseIdentifier
    parseNumber
  ];
  
  parseSExpr = combs.mapParser
    (label "s-expr")
    (combs.between
      (combs.char "(") (combs.char ")")
      (combs.many parseElem));
  
  parseBoolean = combs.mapParser
    (utils.compose (label "boolean") (s: s == "true"))
    (combs.alternative [
       (combs.parseStr "true")  
       (combs.parseStr "false")  
    ]);

  parseOp = combs.mapParser
    (label "op")
    (combs.alternative [
      (combs.char "+")
      (combs.char "-")
      (combs.char "*")
      (combs.parseStr ">=")
      (combs.parseStr "<=")
      (combs.char "=")
      (combs.char ">")
      (combs.char "<")
      (combs.parseStr "let")
      (combs.parseStr "not")
      (combs.parseStr "or")
      (combs.parseStr "and")
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
    (utils.compose (label "identifier") utils.combineChars)
    (combs.headAndRest
      (combs.charRange "A" "z")
      (combs.alternative [
        (combs.charRange "0" "z")
        (combs.char "-")
        (combs.char "_")
      ]));

in
parseElem
