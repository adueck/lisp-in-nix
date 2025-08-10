# LISP in Nix

![Testing](https://github.com/adueck/lisp-in-nix/actions/workflows/testing.yaml/badge.svg)

I wanted to learn the Nix language. I heard that that Nix was Turing-complete, so I wrote a little LISP-style calculator in it.

I also wanted to go way overboard and practice some FP so of course I used:

- For the **parser**: A Parser monad and parser combinators
- For the **evaluator**: A hybrid monad which is a blending of:
  - an Either monad for handling errors in evaluation
    - *because I can't be bothered to manually error handle each result.*
  - a State monad for keeping track of the environment
    - *because why manually pass the environment around to the different eval functions like a caveman? After all, we're writing an interpreter in a fully-functional configuration DSL inspired by Haskell. Let's go all out on this. This ended up becoming wayyy worse for handling the environment for lambda applications, but oh well, that's the price you pay for FP glory.*

This was all done in straight-up vanilla Nix with just the [builtins](https://nix.dev/manual/nix/2.18/language/builtins). No [lib.strings](https://ryantm.github.io/nixpkgs/functions/library/strings/) or **lib.** anything here.

**Can YAML do that? I didn't think so.**

Should YAML, or any config DSL do this? Probably also no. Should *I* have done this? Don't ask that.

## Features

- LISP-style syntax
- Primitives (follwing common LISP functionality)
    - `+` `*` `-` `=` `>` `<` `>=` `<=` `not` `and` `or` `if`
    - **TODO:** `number?` `bool?` `lambda?`
- Data types
    - int (no floats)
    - boolean
- Identifiers / variables with `let`
- Lambdas (single parameter)

### 🚧 Roadmap (that will probably never happen)

- strings
- records
- lists
- static types
- type inference
- type classes
- dependent types
- effect & resource dependent types
- homotopy type theory (HoTT)

## Requirements

- Nix

## Runing the Evaluator

Edit `source.lisp`, to contain soething one expression you want to evaluate, like:

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
