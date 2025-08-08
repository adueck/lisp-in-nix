let
  stringToCharacters = str:
    builtins.map
      (i: builtins.substring i 1 str)
      (builtins.genList (i: i) (builtins.stringLength str));
  
  getChars = src: stringToCharacters
      (builtins.readFile src);
  getTokens = file: getChars file;
in
getTokens

