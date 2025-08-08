let
  # TODO: could re-work things to allow operations to be stored to variables!

  eval = env: ast: if ast.type == "number"
    then ast.value
    else if ast.type == "op"
    then "operation: ${ast.value}"
    else if ast.type == "identifier"
    then lookup env ast.value 
    else evalSExpr env ast.value;

  lookup = env: id:
    let
      ok = builtins.hasAttr id env;
    in if ok then
      builtins.getAttr id env
      else false;

  evalSExpr = env: s: if (builtins.length s) == 0
    then false
    else let
      first = builtins.head s;
      rest = builtins.tail s;
    in if (first.type != "op")
      then false
      else evalOp env first.value rest; 
 
  evalOp = env: op: args: let
    f = if (op == "+") then add
      else if (op == "*") then multiply
      else if (op == "-") then subtract
      else if (op == "let") then doLet
      else false;
    in if f == false
      then false
      else f env args;

  doLet = env: args: if (builtins.length args) != 2
    then false
    else let
      dec = builtins.head args;
      body = builtins.head (builtins.tail args);
    in let
      newEnv = addDeclaration env dec;
    in if newEnv == false
      then false
      else eval newEnv body;

  addDeclaration = env: dec: if (dec.type != "s-expr")
    then false
    else builtins.foldl' (acc: curr: 
      if acc == false
        then false
        else addOneDec acc curr
    ) env dec.value;

  addOneDec = env: dec: if (dec.type != "s-expr") || (builtins.length dec.value) != 2
    then false
    else let
      id = builtins.head dec.value;
      assigned = builtins.head (builtins.tail dec.value);
    in if id.type != "identifier"
      then false
      else let
        val = eval env assigned;
      in if val == false
        then false
        else env // { "${id.value}" = val; };

  add = env: args: if (builtins.length args) == 0
    then 0
    else let
      first = builtins.head args;
      rest = builtins.tail args;
      front = eval env first;
    in if builtins.typeOf front != "int"
      then false
      else front + (add env rest);
  
  subtract = env: args: if (builtins.length args) == 0
    then false  
    else let
      first = builtins.head args;
      rest = builtins.tail args;
      front = eval env first;
    in if builtins.typeOf front != "int"
      then false
      else
        if (builtins.length rest == 0)
          then - front
          else front - (add env rest);

  multiply = env: args: if (builtins.length args) == 0
    then 1
    else let
      first = builtins.head args;
      rest = builtins.tail args;
      front = eval env first;
    in if builtins.typeOf front != "int"
      then false
      else front * (multiply env rest);

in
eval
