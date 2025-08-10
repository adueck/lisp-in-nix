# OUTPUT MODAD TYPE FOR EVAL
# { ok = true; value = VAL; } | { ok = false; error = STRING; }

# ...could also make some kind of state monad to avoid passing env all the time

let
  utils = import ../utils/utils.nix;

  # utility functions for result monad
  fail = msg: { ok = false; error = msg; };
  pass = value: { ok = true; inherit value; };
  bindRes = v: f:
    if !v.ok then v
    else f v.value;
  # end of utility functions

  # TODO: check if recursion works with lambdas

  eval = env: ast: if (ast.type == "number") || (ast.type == "boolean")
    then pass ast.value
    else if ast.type == "op"
    then pass "operation: ${ast.value}"
    else if ast.type == "identifier"
    then lookup env ast.value
    else evalSExpr env ast.value;

  lookup = env: id:
    if builtins.hasAttr id env
      then pass (builtins.getAttr id env)
      else fail "variable ${id} not found";

  evalSExpr = env: s: if (builtins.length s) == 0
    then fail "S-Expr must have at least one element"
    else let
      inherit (utils.getHead s) first rest;
    in if (first.type == "op")   
      then evalOp first.value env rest
      else evalSExprWLambda env first rest;

  evalSExprWLambda = env: lambda: args: if (builtins.length args) != 1
    then fail "function can only be applied to one argument"
    else bindRes
      (eval env lambda)
      (lv: if lv.type != "lambda"
        then fail "not a function at the beginning of a S-Expr"
        else evalLambda env lv (builtins.head args));

  evalOp = op: (builtins.getAttr op opTable); 

  doLet = env: args: if (builtins.length args) != 2
    then fail "let expression must have two arguments"
    else let
      inherit (utils.getHead args) first rest;
      body = builtins.head rest;
    in bindRes
      (addDeclaration env first)
      (nenv: eval nenv body);

  doNot = env: args: if (builtins.length args) != 1
    then fail "not expression must have one argument"
    else bindRes
      (eval env (builtins.head args))
      (v: pass (v == false));

  doIf = env: args: if (builtins.length args) != 3
    then fail "if expression must have three args"
    else let
      cond = builtins.head args;
      a = builtins.head (builtins.tail args);
      b = builtins.head (builtins.tail (builtins.tail args));
    in bindRes
      (eval env cond)
      (v: eval env (if (v == false) then b else a));

  addDeclaration = env: dec: if (dec.type != "s-expr")
    then fail "invalid declaration section"
    else builtins.foldl'
      (acc: curr: bindRes acc (a: addOneDec a curr))
      (pass env)
      dec.value; 

  addOneDec = env: dec: if (dec.type != "s-expr") || (builtins.length dec.value) != 2
    then fail "invalid declaration"
    else let
      id = builtins.head dec.value;
      assigned = builtins.head (builtins.tail dec.value);
    in if id.type != "identifier"
      then fail "first element in declaration must be a variable"
      else bindRes
        (eval env assigned)
        (v: pass (env // { "${id.value}" = v; }));

  equals = env: args: if (builtins.length args) == 0
    then fail "= requires argument(s)"
    else let
      inherit (utils.getHead args) first rest;
    in bindRes
      (eval env first)
      (v: equals' env v rest);

  equals' = env: val: args:
    if (builtins.length args) == 0
      then pass true
      else let
        inherit (utils.getHead args) first rest;
      in bindRes
        (eval env first)
        (v: if (v != val)
          then pass false
          else equals' env val rest);

  doOr = env: args: if (builtins.length args) == 0
    then pass false
    else let
      inherit (utils.getHead args) first rest;
    in bindRes
      (eval env first)
      (v: if v != false
        then pass true
        else doOr env rest);

  doAnd = env: args: if (builtins.length args) == 0
    then pass true
    else let
      inherit (utils.getHead args) first rest;
    in bindRes
      (eval env first)
      (v: if v == false
        then pass false
        else doAnd env rest);

  comp = dir: env: args: if (builtins.length args) == 0
    then fail "comparison requires arg(s)"
    else let
      inherit (utils.getHead args) first rest;
    in bindRes
      (eval env first)
      (v: if builtins.typeOf v != "int"
        then fail "comparison only works on ints"
        else comp' dir env v rest);

  comp' = dir: env: val: args:
    if (builtins.length args) == 0
      then pass true
      else let
        inherit (utils.getHead args) first rest;
      in bindRes
        (eval env first)
        (v: if builtins.typeOf v != "int"
          then fail "comparison only works on ints"
          else if (if dir == "gt" then !(val > v)
            else if dir == "lt" then !(val < v)
            else if dir == "gte" then !(val >= v)
            else !(val <= v))
          then pass false
          else comp' dir env v rest);

  add = env: args: if (builtins.length args) == 0
    then pass 0
    else let
      inherit (utils.getHead args) first rest;
    in bindRes
      (eval env first)
      (fr: if builtins.typeOf fr != "int"
        then fail "+ only works on ints"
        else bindRes
          (add env rest)
          (r: pass (fr + r)));
  
  subtract = env: args: if (builtins.length args) == 0
    then fail "- requires arg(s)" 
    else let
      inherit (utils.getHead args) first rest;
    in bindRes
      (eval env first)
      (fr: if builtins.typeOf fr != "int"
        then fail "- only works on ints"
        else if (builtins.length rest == 0)
        then pass (-fr)
        else bindRes
          (add env rest)
          (r: pass (fr - r)));

  multiply = env: args: if (builtins.length args) == 0
    then pass 1
    else let
      inherit (utils.getHead args) first rest;
    in bindRes
      (eval env first)
      (fr: if builtins.typeOf fr != "int"
        then fail "* only works on ints"
        else bindRes
          (multiply env rest)
          (r: pass (fr * r)));


  doLambda = env: args: if (builtins.length args) != 2
    then fail "lambda expression requires two args"
    else let
      inherit (utils.getHead args) first rest;
      param = first;
      body = builtins.head rest;
    in if param.type != "identifier"
      then fail "lambda parameter must be a single identifier"
      else pass {
        type = "lambda";
        param = param.value;
        inherit body env;
      };

  evalLambda = env: lambda: arg:
    bindRes
      (eval env arg)
      (av: eval
        (env // lambda.env // { "${lambda.param}" = av; })
        lambda.body);
        
  opTable = {
    "+" = add;
    "*" = multiply;
    "-" = subtract;
    "=" = equals;
    ">" = comp "gt";
    "<" = comp "lt";
    ">=" = comp "gte";
    "<=" = comp "lte";
    "let" = doLet;
    "not" = doNot;
    "or" = doOr;
    "and" = doAnd;
    "if" = doIf;
    "lambda" = doLambda;
  };

in
eval
