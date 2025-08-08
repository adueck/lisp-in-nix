let
  getTokens = import ./tokenizer/tokenizer.nix;
  parse = import ./parser/parse.nix;
  eval = import ./evaluator/eval.nix;
  ast = parse (getTokens (builtins.readFile ./source.lisp));
in

if (ast == false)
  then "SYNTAX ERROR: invalid expression"
  else if (builtins.length ast.tokens) == 0
    then let
      res = eval {} ast.body;
    in if res == false
      then "ERROR: invalid expression"
      else res
    else "ERROR: invalid expression - trailing tokens"
