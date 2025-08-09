let
  combs = import ./combinators.nix;
  parseNumber = import ./parse-number.nix;

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
      (combs.parseStr "#|")
      (combs.parseStr "|#"))
  ];

  parseIdentifier = combs.mapParser
    (value: {
      type = "identifier";
      value = combineChars value;
    })
    (combs.mapParser
      builtins.concatLists
      (combs.successive
        [
          (combs.some (combs.charRange "a" "z"))
          (combs.many (combs.alternative [
            (combs.charRange "0" "z")
            (combs.char "-")
            (combs.char "_")
          ]))
        ]));

  combineChars = xs: if (builtins.length xs == 0)
    then ""
    else let
      first = builtins.head xs;
      rest = builtins.tail xs;
    in first + (combineChars rest);

in
parseElem
