; calculate the 7th value of the fibobonaci sequence
(let
  (
    ; functions are defined as lambdas bound to identifiers
    (fibb (lambda n    
      (if (< n 3)
      n
      (+ 
        (fibb (- n 2)) #| recursion! |# (fibb (- n 1)))))
    )
  )
  ; call the function with 7 to get the 7th value
  (fibb 7)
)
