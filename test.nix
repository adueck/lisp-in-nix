let 
  tokenize = import ./tokenizer/tokenizer.nix;
  parse = import ./parser/parse.nix;
  eval = import ./evaluator/eval.nix;
  tests = [
    # { input = "1"; output = 1; }
    # { input = "27345"; output = 27345; }
    { input = "(+ 1 2)"; output = 3; }
    { input = "(+)"; output = 0; }
    { input = "(+ 5)"; output = 5; }
    { input = "(+ 1 2 3 4 5)"; output = 15; }
    { input = "(-)"; output = false; }
    { input = "(- 5)"; output = -5; }
    { input = "(- 10 2 1)"; output = 7; }
    { input = "(*)"; output = 1; }
    { input = "(* 20)"; output = 20; }
    { input = "(* 5 10 2)"; output = 100; }
    { input = ''
      (+ 10
        (* 2 3)
        (-3))
    ''; output = 13; }
  ];
  runTest = test: let
    tokens = tokenize test.input;
    ast = parse tokens;
  in if (builtins.length ast.tokens) != 0
    then { input = test.input; passed = false; error = "trailing tokens"; }
  else let
    result = eval ast.body;
  in if (result == test.output)
    then { input = test.input; passed = true; }
    else { input = test.input; passed = false; expected = test.output; received = result; };
  testResults = builtins.map runTest tests;
  report = builtins.foldl'
    (acc: elem: if elem.passed then acc + "" else acc + "input: " + elem.input + " ")
    ""
    testResults;
in
if report == ""
  then "ALL " + (builtins.toString (builtins.length tests)) + " TESTS PASSED!"
  else abort ("FAILED ON " + report)

