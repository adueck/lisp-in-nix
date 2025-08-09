# takes a string and returns a list of chars
str: builtins.map
  (i: builtins.substring i 1 str)
  (builtins.genList (i: i) (builtins.stringLength str))
