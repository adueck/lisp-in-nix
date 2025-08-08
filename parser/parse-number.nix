let
  parseNumber = prev: tokens: if (builtins.length tokens) == 0
    then if (builtins.length prev == 0) then false
      else {
        tokens = [ ];
        body = {
          type = "number";
          value = digitsToNumber prev;
        };
      }
    else let
      first = builtins.head tokens;
      rest = builtins.tail tokens;
      digit = toDigit first;
    in if digit == 0 && (builtins.length prev == 0) then false
      else if digit == false
      then
        if (builtins.length prev == 0)
          then false
          else {
            tokens = tokens;
            body = {
              type = "number";
              value = digitsToNumber prev;
            };
          }
      else parseNumber (builtins.concatLists [prev [digit]]) rest;

  digitsToNumber = digits: if (builtins.length digits) == 0
    then 0
    else let
      first = builtins.head digits;
      rest = builtins.tail digits;
      front = first * (power 10 (builtins.length rest));
    in front + digitsToNumber rest;

  power = base: exp: if exp == 0 then 1 else base * power base (exp - 1);

  toDigit = first: if first == "1"
    then 1
    else if first == "2"
    then 2
    else if first == "3"
    then 3
    else if first == "4"
    then 4
    else if first == "5"
    then 5
    else if first == "6"
    then 6
    else if first == "7"
    then 7
    else if first == "8"
    then 8
    else if first == "9"
    then 9
    else if first == "0"
    then 0
    else false;
in
parseNumber
