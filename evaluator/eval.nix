# STATE/EITHER MONAD FOR ENCAPSULATING BOTH ENV AND SUCCESS/FAIL
#
# type State = ENV -> {
#   result = { ok = true; value = VAL; } | { ok = false; error = STRING; };
#   env = ENV;
# }

let
  utils = import ../utils/utils.nix;

  # ENV STATE MONAD

  # return (a successful evaluation)
  # VAL -> State
  pass = value:
    env: {
      inherit env;
      result = { ok = true; inherit value; };
    };

  # return (an error)
  # String -> State
  fail = error:
    env: {
      inherit env;
      result = { ok = false; inherit error; };
    };
   
  # >>=
  # State -> (VAL -> State) -> State
  bind = m0: f:
    env: let
      m1 = m0 env;
    in if (m1.result.ok)
      then (f m1.result.value) m1.env
      else m1;

  # >>
  # State -> State -> State
  apply = m0: m1:
    env: let
      m2 = m0 env;
    in if (m2.result.ok)
      then m1 m2.env
      else m2;

  # applyMap takes a function that generates a monad from each member of
  # a NON-EMPTY list and applies the resulting monads in order
  #
  # f [a]
  # f a
  #
  # f [a, b]
  # apply (f a) (f b)
  #
  # f [a, b, c]
  # (apply (apply (f a) (f b)) (f c)))
  #
  # f [a, b, c, d]
  # (apply (apply (apply (f a) (f b)) (f c))) (f d))))
  #
  # TODO: check out Haskell - there might be a better way to implement this
  # look for type signature
  # TODO: also see if there's a better name
  # (a -> m s) -> [a] -> m s
  #
  # (Exp -> State) -> [Exp] -> State
  applyMap = f: ms: if (builtins.length ms) == 0
    then abort "tried calling applyMap on an empty list of ms"
    else if (builtins.length ms) == 1
    then f (builtins.head ms)
    else if (builtins.length ms) == 2
    then let
      inherit (utils.getHead ms) first rest;
    in apply (f first) (f (builtins.head rest))
    else applyMap'
      f
      (applyMap f (utils.take2 ms))
      (builtins.tail (builtins.tail ms));

  applyMap' = f: inside: ms: if (builtins.length ms) == 0
    then inside
    else let
      inherit (utils.getHead ms) first rest;
    in applyMap' f (apply inside (f first)) rest;
      
  # fmap
  # TODO: not needed but do anyways 

  # Env -> State
  updateEnv = env:
    _: {
      result = { ok = true; value = null; };
      inherit env;
    };

  # Env -> State
  addToEnv = toAdd:
    env: {
      result = { ok = true; value = null; };
      env = env // toAdd;
    };

  # State
  getEnv = env: {
    result = { ok = true; value = env; };
    inherit env;
  };

  # Exp -> State
  eval = ast: if ast.type == "number" || ast.type == "boolean"
    then pass ast.value
    else if ast.type == "s-expr"
    then evalSExpr ast.value
    else if ast.type == "identifier"
    then lookup ast.value
    else fail "BAD STATEMENT";

  # ID -> State
  lookup = id: (bind
    getEnv (env:
      if builtins.hasAttr id env
        then pass (builtins.getAttr id env)
        else fail "variable ${id} not found"));

  # Exp -> State
  evalSExpr = s: if (builtins.length s) == 0
    then fail "S-Expr must have at least one element"
    else let
      inherit (utils.getHead s) first rest;
    in if (first.type == "op")   
      then evalOp first.value rest
      else evalSExprWLambda first rest;

  # Op -> ([Exp] -> State)
  evalOp = op: (builtins.getAttr op opTable);

  opTable = {
    "+" = add;
    "*" = multiply;
    "-" = subtract;
    "=" = equals;
    ">" = comp "gt";
    "<" = comp "lt";
    ">=" = comp "gte";
    "<=" = comp "lte";
    "not" = doNot;
    "and" = doAnd;
    "or" = doOr;
    "if" = doIf;
    "let" = doLet;
    "lambda" = doLambda;
  };
 
  # [Exp] -> State
  add = args: if (builtins.length args) == 0
    then pass 0
    else let
      inherit (utils.getHead args) first rest;
    in bind
      (eval first)
      (fr: if (builtins.typeOf fr) != "int"
        then fr (fail "+ only works on ints")
        else bind
          (add rest)
          (r: pass (fr + r)));
 
  # [Exp] -> State
  subtract = args: if (builtins.length args) == 0
    then fail "- requires arg(s)" 
    else let
      inherit (utils.getHead args) first rest;
    in bind
      (eval first)
      (fr: if builtins.typeOf fr != "int"
        then fail "- only works on ints"
        else if (builtins.length rest == 0)
        then pass (-fr)
        else bind
          (add rest)
          (r: pass (fr - r)));

  # [Exp] -> State
  multiply = args: if (builtins.length args) == 0
    then pass 1
    else let
      inherit (utils.getHead args) first rest;
    in bind
      (eval first)
      (fr: if builtins.typeOf fr != "int"
        then fail "* only works on ints"
        else bind
          (multiply rest)
          (r: pass (fr * r)));

  # [Exp] -> State
  equals = args: if (builtins.length args) == 0
    then fail "= requires argument(s)"
    else let
      inherit (utils.getHead args) first rest;
    in bind
      (eval first)
      (v: equals' v rest);

  equals' = val: args:
    if (builtins.length args) == 0
      then pass true
      else let
        inherit (utils.getHead args) first rest;
      in bind
        (eval first)
        (v: if (v != val)
          then pass false
          else equals' val rest);

  # Op -> [Exp] -> State
  comp = dir: args: if (builtins.length args) == 0
    then fail "comparison requires arg(s)"
    else let
      inherit (utils.getHead args) first rest;
    in bind
      (eval first)
      (v: if builtins.typeOf v != "int"
        then fail "comparison only works on ints"
        else comp' dir v rest);

  comp' = dir: val: args:
    if (builtins.length args) == 0
      then pass true
      else let
        inherit (utils.getHead args) first rest;
      in bind
        (eval first)
        (v: if builtins.typeOf v != "int"
          then fail "comparison only works on ints"
          else if (if dir == "gt" then !(val > v)
            else if dir == "lt" then !(val < v)
            else if dir == "gte" then !(val >= v)
            else !(val <= v))
          then pass false
          else comp' dir v rest);

  # [Exp] -> State
  doNot = args: if (builtins.length args) != 1
    then fail "not expression must have one argument"
    else bind
      (eval (builtins.head args))
      (v: pass (v == false));

  # [Exp] -> State
  doAnd = args: if (builtins.length args) == 0
    then pass true
    else let
      inherit (utils.getHead args) first rest;
    in bind
      (eval first)
      (v: if v == false
        then pass false
        else doAnd rest);
  
  # [Exp] -> State
  doOr = args: if (builtins.length args) == 0
    then pass false
    else let
      inherit (utils.getHead args) first rest;
    in bind
      (eval first)
      (v: if v != false
        then pass true
        else doOr rest);
  
  # [Exp] -> State
  doIf = args: if (builtins.length args) != 3
    then fail "if expression must have three args"
    else let
      cond = builtins.head args;
      a = builtins.head (builtins.tail args);
      b = builtins.head (builtins.tail (builtins.tail args));
    in bind
      (eval cond)
      (v: eval (if (v == false) then b else a));

  # [Exp] -> State
  doLet = args: if (builtins.length args) != 2
    then fail "let expression must have two arguments"
    else let
      inherit (utils.getHead args) first rest;
      body = builtins.head rest;
    in if first.type != "s-expr"
      then fail "let expression must take a S-Expr of assignments as the first argument"
      else apply
        (applyMap addOneDec first.value)
        (eval body);
  
  # Exp -> State
  addOneDec = dec:
    if (dec.type != "s-expr") || (builtins.length dec.value) != 2
      then fail "invalid declaration"
      else let
        id = builtins.head dec.value;
        assigned = builtins.head (builtins.tail dec.value);
      in if id.type != "identifier"
        then fail "first element in declaration must be a variable"
        else bind
          (eval assigned)       
          (v: addToEnv { "${id.value}" = v; });

  evalSExprWLambda = lambda: args: if (builtins.length args) != 1
    then fail "function can only be applied to one argument"
    else bind
      (eval lambda)
      (lv: if lv.type != "lambda"
        then fail "not a function at the beginning of a S-Expr"
        else evalLambda lv (builtins.head args));

  # [Exp] -> State
  doLambda = args: if (builtins.length args) != 2
    then fail "lambda expression requires two args"
    else let
      inherit (utils.getHead args) first rest;
      param = first;
      body = builtins.head rest;
    in if param.type != "identifier"
      then fail "lambda parameter must be a single identifier"
      else bind getEnv (env: pass {
          type = "lambda";
          param = param.value;
          inherit body env;
        });

  # absolutely horrific workaround to keep the environment passed
  # through the monad in check while evaluating lambdas (otherwise there
  # is a problem with recursive calls using the same variables as in the
  # fibbonaci example)
  evalLambda = lambda: arg:
    # before we do any lambda application - get the untouched environment
    (bind getEnv (oldEnv:
      # then do all the stuff with assigning the lambda evaluation environment
      # and the value of the argument
      (apply
       (bind
        (eval arg)
        (av: 
          addToEnv (lambda.env // { "${lambda.param}" = av; }))))
    (bind
      (eval lambda.body)
      # then after all that put the old environment back in the state
      # so that the stuff we added for the lambda application doesn't stick
      # but to do that, we have to first grab the value from the body
      # and then pass/return it out finally because if we just close the
      # monad by running updateEnv then it will override the value with null
      (val: 
        (apply
          (updateEnv oldEnv)
          (pass val))))
      ));
    # I thought I was being clever by using a State monad for the environment
    # and I got to remove a few extra function parameters - but I ended up with
    # this absolute monstrosity that is on order of magnitude worse than any of
    # other code that I was 'cleaning up' with the state monad. But I will keep
    # it this way, as my pride will not let me go back to before I refactored
    # to use the state monad.
    # ... and it's not only this - have a look at the applMap function above.
    # I also had to create that.
in
eval
