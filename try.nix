let
  getTokens = import ./tokenizer/tokenizer.nix;
  parse = import ./parser/parse.nix;
  eval = import ./evaluator/eval.nix;
  combs = import ./parser/combinators.nix;
  tokens = getTokens "{+ 1 2}{ -   3  }";
  parseSExp = (combs.bindParser
    (combs.thenParser     
      (combs.parseChar "{")
      (combs.many parse.parseElem))
    (val: combs.mapParser (_: { type = "s-expr"; value = val; }) (combs.parseChar "}")));
in
  (combs.many parseSExp) tokens


