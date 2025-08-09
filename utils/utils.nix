# takes a string and returns a list of chars
let
  strToChars = str: builtins.map
    (i: builtins.substring i 1 str)
    (builtins.genList (i: i) (builtins.stringLength str));

  compose = f: g: x:
    f (g x);

in
{ 
  inherit
    strToChars
    compose;
}

# TODO: a utility for getting first and rest
