let 
  eval = ast: if ast.type == "number"
    then ast.value
    else if ast.type == "op"
    then "operation: ${ast.value}"
    else evalSExpr ast.value;

  evalSExpr = s: if (builtins.length s) == 0
    then false
    else let
      first = builtins.head s;
      rest = builtins.tail s;
    in if (first.type != "op")
      then false
      else evalOp first.value rest; 
 
  evalOp = op: args: let
    f = if (op == "+") then add
      else if (op == "*") then multiply
      else if (op == "-") then subtract
      else false;
    in if f == false
      then false
      else f args;

  add = args: if (builtins.length args) == 0
    then 0
    else let
      first = builtins.head args;
      rest = builtins.tail args;
      front = eval first;
    in if builtins.typeOf front != "int"
      then false
      else front + add rest;
  
  subtract = args: if (builtins.length args) == 0
    then false  
    else let
      first = builtins.head args;
      rest = builtins.tail args;
      front = eval first;
    in if builtins.typeOf front != "int"
      then false
      else
        if (builtins.length rest == 0)
          then - front
          else front - (add rest);

  multiply = args: if (builtins.length args) == 0
    then 1
    else let
      first = builtins.head args;
      rest = builtins.tail args;
      front = eval first;
    in if builtins.typeOf front != "int"
      then false
      else front * multiply rest;
in
eval
