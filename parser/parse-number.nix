let
  combs = import ./combinators.nix;
  utils = import ../utils/utils.nix;

  parseNumber = 
    (combs.mapParser
      (utils.compose
        (value: { type = "number"; inherit value; })
        (utils.compose digitsToNumber (map digitCharToInt)))
      (combs.headAndRest
        (combs.charRange "1" "9")
        (combs.charRange "0" "9")));

  digitsToNumber = digits: if (builtins.length digits) == 0
    then 0
    else let
      inherit (utils.getHead digits) first rest;
      front = first * (power 10 (builtins.length rest));
    in front + digitsToNumber rest;

  power = base: exp: if exp == 0 then 1 else base * power base (exp - 1);

  digitCharToInt = c: if c == "1"
    then 1
    else if c == "2"
    then 2
    else if c == "3"
    then 3
    else if c == "4"
    then 4
    else if c == "5"
    then 5
    else if c == "6"
    then 6
    else if c == "7"
    then 7
    else if c == "8"
    then 8
    else if c == "9"
    then 9
    else 0;

in
parseNumber
