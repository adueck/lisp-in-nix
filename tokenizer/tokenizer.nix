str: builtins.concatLists
  [(builtins.map
    (i: builtins.substring i 1 str)
    (builtins.genList (i: i) (builtins.stringLength str)))
  ["eof"]]
