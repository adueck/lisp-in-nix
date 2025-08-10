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
      r = eval ast.body {};
    in if !r.result.ok
      then "ERROR: ${r.result.error}"
      else r.result.value
    else "ERROR: invalid expression - trailing tokens"
