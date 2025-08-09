let
  combs = import ./combinators.nix;
  utils = import ../utils/utils.nix;
  numTable = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
  };

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

  digitCharToInt = c: builtins.getAttr c numTable;

in
parseNumber
