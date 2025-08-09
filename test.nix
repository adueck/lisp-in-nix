# TODO: also test for errors that should come up

let 
  getTokens = import ./tokenizer/tokenizer.nix;
  parse = import ./parser/parse.nix;
  eval = import ./evaluator/eval.nix;
  tests = [
    { input = " 3 "; output = 3; }
    { input = "27345"; output = 27345; }
    { input = " true "; output = true; }
    { input = "false"; output = false; }
    { input = "(+ 1 2)"; output = 3; }
    { input = "(+)"; output = 0; }
    { input = "(+ 5)"; output = 5; }
    { input = "(+ 1 2 3 4 5)"; output = 15; }
    { input = "(-)"; output = false; }
    { input = "(- 5)"; output = -5; }
    { input = "(-4)"; output = -4; }
    { input = "(- 10 2 1)"; output = 7; }
    { input = "(- 10 2)"; output = 8; }
    { input = "(*)"; output = 1; }
    { input = "(* 20)"; output = 20; }
    { input = "(* 5 10 2)"; output = 100; }
    { input = "(= 3)"; output = true; }
    { input = "(= 3 (+ 1 2))"; output = true; }
    { input = "(= 5 5 5 5 (+ 2 3))"; output = true; }
    { input = "(= 5 1 5 5 (+ 2 3))"; output = false; }
    { input = "(= 5 5 5 5 (+ 1 3))"; output = false; }
    { 
      input = ''
        (+ 10
          (  * 2   3)
          (-3))
      '';
      output = 13;
    }
    {
      input = ''; this is a comment
      (+ 2 #| this is inline |# 3) ;;;; that was cool
    ;goodbye'';
      output = 5;
    }
    {
      input = "(let ((x 10) (y (+ 2 3))) (+ x y))";
      output = 15;
    }
    {
      input = ''(let ((foo 1) (bar 10))
      (let ((baz 2)) (* (+ foo baz) bar)))'';
      output = 30;
    }
    {
      input = ''(let ((foo 1) (bar 10))
      ; shadowed identifiers overwrite previous scope
      (let ((foo 2)) (+ foo bar)))'';
      output = 12;
    }
    # undeclared identifier
    {
      input = "myVar_starts-with-LOWERCASE1of3StUfF";
      output = false;
    }
  ];
  runTest = test: let
    ast = parse (getTokens test.input);
  in if (ast == false)
    then { passed = false; error = "invalid syntax"; input = test.input; }
    else if (builtins.length ast.tokens != 0)
    then { passed = false; error = "trailing tokens"; input = test.input; }
    else let
      result = eval {} ast.body;
    in if (result.ok && result.value == test.output || !result.ok && test.output == false)
      then { passed = true; }
      else { passed = false; error = "incorrect evaluation"; input = test.input; };
  testResults = builtins.map runTest tests;
  report = builtins.foldl'
    (acc: elem: if elem.passed then acc + "" else acc + "input: " + elem.input + " ")
    ""
    testResults;
in
if report == ""
  then "✅ ALL " + (builtins.toString (builtins.length tests)) + " TESTS PASSED!"
  else abort ("FAILED ON " + report)

