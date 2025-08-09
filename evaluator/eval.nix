# OUTPUT MODAD TYPE FOR EVAL
# { ok = true; value = VAL; } | { ok = false; }

# ...could also make some kind of state monad to avoid passing env all the time

let
  utils = import ../utils/utils.nix;

  # utility functions for result monad
  fail = { ok = false; };
  pass = value: { ok = true; inherit value; };
  bindRes = v: f:
    if !v.ok then v
    else f v.value;
  # end of utility functions

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
      else fail;

  evalSExpr = env: s: if (builtins.length s) == 0
    then fail
    else let
      inherit (utils.getHead s) first rest;
    in if (first.type != "op")
      then fail
      else evalOp env first.value rest; 
 
  evalOp = env: op: args:
    bindRes 
      (if (op == "+") then pass add
        else if (op == "*") then pass multiply
        else if (op == "-") then pass subtract
        else if (op == "=") then pass equals
        else if (op == ">") then pass (comp "gt")
        else if (op == "<") then pass (comp "lt")
        else if (op == ">=") then pass (comp "gte")
        else if (op == "<=") then pass (comp "lte")
        else if (op == "let") then pass doLet
        else if (op == "not") then pass doNot
        else if (op == "or") then pass doOr
        else if (op == "and") then pass doAnd
        else if (op == "if") then pass doIf
        else fail)
      (f: f env args);

  doLet = env: args: if (builtins.length args) != 2
    then fail
    else let
      inherit (utils.getHead args) first rest;
      body = builtins.head rest;
    in bindRes
      (addDeclaration env first)
      (nenv: eval nenv body);

  doNot = env: args: if (builtins.length args) != 1
    then fail
    else bindRes
      (eval env (builtins.head args))
      (v: pass (v == false));

  doIf = env: args: if (builtins.length args) != 3
    then fail
    else let
      cond = builtins.head args;
      a = builtins.head (builtins.tail args);
      b = builtins.head (builtins.tail (builtins.tail args));
    in bindRes
      (eval env cond)
      (v: eval env (if (v == false) then b else a));

  addDeclaration = env: dec: if (dec.type != "s-expr")
    then fail
    else builtins.foldl'
      (acc: curr: bindRes acc (a: addOneDec a curr))
      (pass env)
      dec.value; 

  addOneDec = env: dec: if (dec.type != "s-expr") || (builtins.length dec.value) != 2
    then fail
    else let
      id = builtins.head dec.value;
      assigned = builtins.head (builtins.tail dec.value);
    in if id.type != "identifier"
      then fail
      else bindRes
        (eval env assigned)
        (v: pass (env // { "${id.value}" = v; }));

  equals = env: args: if (builtins.length args) == 0
    then fail
    else let
      inherit (utils.getHead args) first rest;
      front = eval env first;
    in if !front.ok
      then fail
      else equals' env front.value rest;

  equals' = env: val: args:
    if (builtins.length args) == 0
      then pass true
      else let
        inherit (utils.getHead args) first rest;
        res = eval env first;
      in if !res.ok
        then fail
        else if (res.value != val)
        then pass false
        else equals' env val rest;

  doOr = env: args: if (builtins.length args) == 0
    then pass false
    else let
      inherit (utils.getHead args) first rest;
      front = eval env first;
    in if !front.ok
      then fail
      else if front.value != false
        then pass true
        else doOr env rest;

  doAnd = env: args: if (builtins.length args) == 0
    then pass true
    else let
      inherit (utils.getHead args) first rest;
      front = eval env first;
    in if !front.ok
      then fail
      else if front.value == false
        then pass false
        else doAnd env rest;

  comp = dir: env: args: if (builtins.length args) == 0
    then fail
    else let
      inherit (utils.getHead args) first rest;
      front = eval env first;
    in if !front.ok
      then fail
      else if builtins.typeOf front.value != "int"
      then fail
      else comp' dir env front.value rest;

  comp' = dir: env: val: args:
    if (builtins.length args) == 0
      then pass true
      else let
        inherit (utils.getHead args) first rest;
        res = eval env first;
      in if !res.ok
        then fail
        else if builtins.typeOf res.value != "int"
        then fail
        else if (if dir == "gt" then !(val > res.value)
          else if dir == "lt" then !(val < res.value)
          else if dir == "gte" then !(val >= res.value)
          else !(val <= res.value))
        then pass false
        else comp' dir env res.value rest;

  add = env: args: if (builtins.length args) == 0
    then pass 0
    else let
      inherit (utils.getHead args) first rest;
      front = eval env first;
    in bindRes
      front
      (fr: if builtins.typeOf fr != "int"
        then fail
        else bindRes
          (add env rest)
          (r: pass (fr + r)));
  
  subtract = env: args: if (builtins.length args) == 0
    then fail 
    else let
      inherit (utils.getHead args) first rest;
      front = eval env first;
    in bindRes
      front
      (fr: if builtins.typeOf fr != "int"
        then fail
        else if (builtins.length rest == 0)
        then pass (-fr)
        else bindRes
          (add env rest)
          (r: pass (fr - r)));

  multiply = env: args: if (builtins.length args) == 0
    then pass 1
    else let
      inherit (utils.getHead args) first rest;
      front = eval env first;
    in bindRes
      front
      (fr: if builtins.typeOf fr != "int"
        then fail
        else bindRes
          (multiply env rest)
          (r: pass (front.value * r)));

in
eval
