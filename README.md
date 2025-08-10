# LISP in Nix

![Testing](https://github.com/adueck/lisp-in-nix/actions/workflows/testing.yaml/badge.svg)

I wanted to learn the Nix language. I heard that that Nix was Turing-complete, so I wrote a little LISP-style calculator in it using monads and parser combinators 🤓. This was all done in straight-up vanilla Nix with just the [builtins](https://nix.dev/manual/nix/2.18/language/builtins), no [lib.strings](https://ryantm.github.io/nixpkgs/functions/library/strings/).

**Can YAML do that? I didn't think so.**

## Features

- LISP-style syntax
- Primitives (follwing common LISP functionality)
    - `+` `*` `-` `=` `>` `<` `>=` `<=` `not` `and` `or` `if`
    - *TODO* `number?` `bool?` `lambda?`
- Data types
    - int (no floats)
    - boolean
- Identifiers / variables with `let`
- Lambdas (single parameter)

## Requirements

- Nix

## Runing the Evaluator

Edit `source.lisp`, to contain something one expression you want to evaluate, like:

```lisp
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
```

Run `nix-instantiate --eval` to evaluate the source.

```bash
$ nix-instantiate --eval
21
```

## Testing

```bash
$ nix-instantiate --eval test.nix
```
