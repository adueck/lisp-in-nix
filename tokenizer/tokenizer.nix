let
  utils = import ../utils/utils.nix;
  getTokens = str: builtins.concatLists [(utils.strToChars str) ["\n"]];
in
getTokens
