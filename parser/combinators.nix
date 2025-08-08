let
  orParser = parsers: tokens:
    if (builtins.length tokens == 0) || (builtins.length parsers) == 0
      then false
      else let
        first = builtins.head parsers;
        rest = builtins.tail parsers;
        result = first tokens;
      in
        if result == false
          then orParser rest tokens
          else result;

  parseChar = char: tokens: if (builtins.length tokens) == 0
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

  # TODO: implement thenParser purely based on bindParser ? 
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
      else many' (builtins.concatLists [[ res.body ] acc]) parser res.tokens;

in
{
  orParser = orParser;
  thenParser = thenParser;
  bindParser = bindParser;
  parseChar = parseChar;
  mapParser = mapParser;
  many = many;
}
