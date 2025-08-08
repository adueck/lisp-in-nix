let
  alternative = parsers: tokens:
    if (builtins.length tokens == 0) || (builtins.length parsers) == 0
      then false
      else let
        first = builtins.head parsers;
        rest = builtins.tail parsers;
        result = first tokens;
      in
        if result == false
          then alternative rest tokens
          else result;

  char = char: tokens: if (builtins.length tokens) == 0
    then false
    else let
      first = builtins.head tokens;
      rest = builtins.tail tokens;
    in if first == char
      then {
        body = char;
        tokens = rest;
      }
      else false;

  charRange = low: high: tokens: if (builtins.length tokens) == 0
    then false
    else let
      first = builtins.head tokens;
      rest = builtins.tail tokens;
    in if first >= low && first <= high
      then {
        body = first;
        tokens = rest;
      }
      else false;

  mapParser = f: p: tokens:
    let
      res = p tokens;
    in if res == false
      then false
    else {
      tokens = res.tokens;
      body = f res.body;
    };

  bindParser = parser: f: tokens: let
      res = parser tokens;
    in if res == false
      then false
      else f res.body res.tokens;

  thenParser = parser: f: tokens: let
      res = parser tokens;
    in if res == false
      then false
      else f res.tokens;

  many = parser: tokens:
    many' [ ] parser tokens;

  many' = acc: parser: tokens:
    let
      res = parser tokens;
    in if res == false
      then { 
        tokens = tokens;
        body = acc;
      }
      else many'
        (builtins.concatLists [ acc [ res.body ] ])
        parser
        res.tokens;

  some = parser: tokens:
    let
      res = many parser tokens;
    in if (builtins.length res.body == 0)
      then false
      else res;

  between = left: right: middle: 
    bindParser
      (thenParser left middle)
      (val:
        mapParser
        (_: val)
        right);

  everythingBetween = left: right: 
    (thenParser left (throwAwayTill right));

  throwAwayTill = closer: tokens:
    if (builtins.length tokens == 0)
      then false
    else let
      res = closer tokens;
    in if res == false
      then throwAwayTill closer (builtins.tail tokens)
      else {
        tokens = res.tokens;
        body = true;
      };
  
  successive = parsers: tokens:
    successive' [] parsers tokens;

  successive' = acc: parsers: tokens:
    if (builtins.length tokens == 0) && (builtins.length parsers != 0)
      then false
    else if (builtins.length parsers == 0)
      then {
        body = acc;
        inherit tokens;
      }
    else let
      firstP = builtins.head parsers;
      restP = builtins.tail parsers;
      res = firstP tokens;
    in if res == false
      then false
      else successive' (builtins.concatLists [acc [res.body]]) restP res.tokens;

in
{
  inherit
    alternative
    char
    charRange
    mapParser
    bindParser
    thenParser
    many
    some
    between
    everythingBetween
    successive;
}
