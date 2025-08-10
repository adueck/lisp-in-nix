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
    { input = "(- 3 2)"; output = 1; }
    { input = "(*)"; output = 1; }
    { input = "(* 20)"; output = 20; }
    { input = "(* 5 10 2)"; output = 100; }
    { input = "(= 3)"; output = true; }
    { input = "(= 3 (+ 1 2))"; output = true; }
    { input = "(= 5 5 5 5 (+ 2 3))"; output = true; }
    { input = "(= 5 1 5 5 (+ 2 3))"; output = false; }
    { input = "(= 5 5 5 5 (+ 1 3))"; output = false; }
    { input = "(= true true true)"; output = true; }
    { input = "(= false false)"; output = true; }
    { input = "(= true true true false true)"; output = false; }
    { input = "(> 4)"; output = true; }
    { input = "(> 4 (+ 4 1))"; output = false; }
    { input = "(> 4 3 2 1)"; output = true; }
    { input = "(> 4 3 3 2 1)"; output = false; }
    { input = "(< 4)"; output = true; }
    { input = "(< 4 (+ 4 1))"; output = true; }
    { input = "(< 4 5 6 7)"; output = true; }
    { input = "(< 4 5 5 6 7)"; output = false; }
    { input = "(>= 4)"; output = true; }
    { input = "(>= 4 4 4 4 4)"; output = true; }
    { input = "(>= 4 (+ 1 1))"; output = true; }
    { input = "(>= 4 3 2 1)"; output = true; }
    { input = "(>= 4 5 2 1)"; output = false; }
    { input = "(>= 4 3 3 2 1)"; output = true; }
    { input = "(<= 4)"; output = true; }
    { input = "(<= 4 4 4 4 4)"; output = true; }
    { input = "(<= 4 (+ 4 1))"; output = true; }
    { input = "(<= 4 5 6 7 8 9)"; output = true; }
    { input = "(<= 4 5 6 5 4)"; output = false; }
    { input = "(<= 4 5 5 6 7)"; output = true; }
    { input = "(not true)"; output = false; }
    { input = "(not false)"; output = true; }
    { input = "(not 23)"; output = false; }
    { input = "(not (= 3 3))"; output = false; }
    { input = "(or)"; output = false; }
    { input = "(or true)"; output = true; }
    { input = "(or false true)"; output = true; }
    { input = "(or false false false)"; output = false; }
    { input = "(or 3 10)"; output = true; }
    { input = "(or false false (= 20 21))"; output = false; }
    { input = "(or false false (= 20 20))"; output = true; }
    { input = "(and)"; output = true; }
    { input = "(and true)"; output = true; }
    { input = "(and true true 23 (= 1 1))"; output = true; }
    { input = "(and true true 23 (= 1 2))"; output = false; }
    { input = "(if true 1 2)"; output = 1; }
    { input = "(if false 1 2)"; output = 2; }
    { input = "(if (= 2 2) (+ 10 1) 5)"; output = 11; }
    { input = "(if (= 2 3) (+ 10 1) 5)"; output = 5; }
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
    {
      input = ''(let ((x 1) (x 2)) x)'';
      output = 2;
    }
    # undeclared identifier
    {
      input = "myVar_starts-with-LOWERCASE1of3StUfF";
      output = false;
    }
    {
      input = "((lambda x (+ x 1)) 3)";
      output = 4;
    }
    {
      input = ''
(let
  (
   (abC (+ 10 1))
   (myf (lambda x (* x 10)))
  )
  (myf 2))'';
      output = 20;
    }
    {
      input = ''
(let
  (
    (x 2)
    (y 3)
    (f (lambda z (+ x y z)))
  )
(f 5))'';
      output = 10;
    }
    {
      input = ''
(let
  (
    (a 10)
    (b 2)
    (getF (lambda y
      (lambda x (+ x b 1))))
    (b 100)
  )
  ((getF true) 3)
)'';
      output = 6; 
    }
    {
      input = ''
(let
  (
    (a 10)
    (getF (lambda y
      (lambda x (+ x b 1))))
  )
  (let
    (
      (b 500) 
    )
    ((getF 1) 2))) 
  '';
      output = 503;
    }
    {
      input = ''
(let
  (
    (a 10)
    (getF (lambda y
      (lambda x (+ x y b 1))))
  )
  (let
    (
      (b 500)
      (y 1000)
    )
    ((getF 21) 2))) 
  '';
      output = 524;
    }
    # {
    #   input = ''
# ; calculate the 7th value of the fibobonaci sequence
# (let
  # (
    # ; functions are defined as lambdas bound to identifiers
    # (fibb (lambda n    
    #   (if (< n 3)
    #   n
    #   (+ 
    #     (fibb (- n 2)) #| recursion! |# (fibb (- n 1)))))
    # )
  # )
  # ; call the function with 7 to get the 7th value
  # (fibb 7)
# )'';
    #   output = 21;
    # }
  ];
  runTest = test: let
    ast = parse (getTokens test.input);
  in if (ast == false)
    then { passed = false; error = "invalid syntax"; input = test.input; }
    else if (builtins.length ast.tokens != 0)
    then { passed = false; error = "trailing tokens"; input = test.input; }
    else let
      r = eval ast.body {};
    in if (r.result.ok && r.result.value == test.output || !r.result.ok && test.output == false)
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

