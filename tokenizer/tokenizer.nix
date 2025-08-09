let
  toChars = import ../utils/to-chars.nix;
  getTokens = str: builtins.concatLists [(toChars str) ["\n"]];
in
getTokens
