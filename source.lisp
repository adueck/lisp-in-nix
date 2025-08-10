
(let
  (
    (a 10)
    (b 2)
    (getF (lambda y
      (lambda x (+ x b 1))))
    (b 100)
  )
  ((getF true) 3))

; basic LISP syntax for calculations
; (let
;   ; declare variables
;   ((x 1) (y 2))
;   (* 
;     (+ x y #| inline comments too |# )
;     10))
