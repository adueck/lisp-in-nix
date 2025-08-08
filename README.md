# LISP in Nix

![Testing](https://github.com/adueck/lisp-in-nix/actions/workflows/testing.yaml/badge.svg)

I wanted to learn the Nix language. I heard that that Nix was Turing-complete, so I wrote a little LISP-style calculator in it using parser combinators 🤓. This is written done purely in this language people use for configuration, using only [builtins](https://nix.dev/manual/nix/2.18/language/builtins), not even [lib.strings](https://ryantm.github.io/nixpkgs/functions/library/strings/).

**Can YAML do that? I didn't think so.**

## Features

- LISP-style polish notation
- Math primitives of `+` `*` and `-`
- Integers only, no floats
- Identifiers / variables
- No lambdas ... yet ?

## System Requirements

- Nix

## Running the calculator

Edit `source.lisp`, to contain something one expression you want to evaluate, like:

```lisp
; basic LISP syntax for calculations
(let
  ; declare variables
  ((x 1) (y 2))
  (* 
    (+ x y #| inline comments too |# )
    10))
```

Run `nix-instantiate --eval` to evaluate the source.

```bash
$ nix-instantiate --eval
30
```

## Testing

```bash
$ nix-instantiate --eval test.nix
```
