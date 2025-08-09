# OUTPUT MODAD TYPE FOR EVAL
# { ok = true; value = VAL; } | { ok = false; }

let
  fail = { ok = false; };
  pass = value: { ok = true; inherit value; };
  bindRes = v: f:
    if !v.ok then v
    else f v.value;

  eval = env: ast: if ast.type == "number"
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
    then { ok = false; }
    else let
      first = builtins.head s;
      rest = builtins.tail s;
    in if (first.type != "op")
      then fail
      else evalOp env first.value rest; 
 
  evalOp = env: op: args: 
    bindRes 
      (if (op == "+") then pass add
        else if (op == "*") then pass multiply
        else if (op == "-") then pass subtract
        else if (op == "let") then pass doLet
        else fail)
      (f: f env args);

  doLet = env: args: if (builtins.length args) != 2
    then fail
    else let
      dec = builtins.head args;
      body = builtins.head (builtins.tail args);
    in bindRes
      (addDeclaration env dec)
      (nenv: eval nenv body);

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

  add = env: args: if (builtins.length args) == 0
    then pass 0
    else let
      first = builtins.head args;
      rest = builtins.tail args;
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
      first = builtins.head args;
      rest = builtins.tail args;
      front = eval env first;
    in bindRes
      front
      (fr: if builtins.typeOf fr != "int"
        then fail
        else if (builtins.length rest == 0)
        then pass (-fr)
        else bindRes
          (subtract env rest)
          (r: pass (fr - r)));

  multiply = env: args: if (builtins.length args) == 0
    then pass 1
    else let
      first = builtins.head args;
      rest = builtins.tail args;
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
