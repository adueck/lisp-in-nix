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

in
{ 
  inherit
    strToChars
    compose
    getHead;
}

# TODO: a utility for getting first and rest
