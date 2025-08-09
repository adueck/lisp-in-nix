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
  
  combineChars = xs: if (builtins.length xs == 0)
    then ""
    else let
      inherit (getHead xs) first rest;
    in first + (combineChars rest);

in
{ 
  inherit
    strToChars
    compose
    getHead
    combineChars;
}

# TODO: a utility for getting first and rest
