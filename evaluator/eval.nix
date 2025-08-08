let 
  eval = env: ast: if ast.type == "number"
    then ast.value
    else if ast.type == "op"
    then "operation: ${ast.value}"
    else evalSExpr env ast.value;

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
      else false;
    in if f == false
      then false
      else f env args;

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
