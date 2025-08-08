; basic LISP syntax for calculations
(let
  ; declare variables
  ((x 1) (y 2))
  (* 
    (+ x y #| inline comments too |# )
    10))
