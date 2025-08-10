# takes a string and returns a list of chars
let
  strToChars = str: builtins.map
    (i: builtins.substring i 1 str)
    (builtins.genList (i: i) (builtins.stringLength str));

  compose = f: g: x:
    f (g x);

  getHead = list:
    let
      first = builtins.head list;
      rest = builtins.tail list;
    in {
      inherit first rest;
    };

  take2 = list:
    let 
      inherit (getHead list) first rest;
    in [first (builtins.head rest)];
  
  combineChars = xs: if (builtins.length xs == 0)
    then ""
    else let
      inherit (getHead xs) first rest;
    in first + (combineChars rest);

  every = f: xs: if (builtins.length xs == 0)
    then true
    else let
      inherit (getHead xs) first rest;
    in if (f first)
      then every rest
      else false;

in
{ 
  inherit
    strToChars
    compose
    getHead
    combineChars
    every
    take2;
}

# TODO: a utility for getting first and rest
