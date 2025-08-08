# LISP in Nix

![Testing](https://github.com/adueck/lisp-in-nix/actions/workflows/testing.yaml/badge.svg)

I wanted to learn the Nix language. I heard that that Nix was Turing-complete, so I wrote a little LISP-style calculator in it using parser combinators 🤓. This was all done in straight-up vanilla Nix with [builtins](https://nix.dev/manual/nix/2.18/language/builtins), no [lib.strings](https://ryantm.github.io/nixpkgs/functions/library/strings/).

**Can YAML do that? I didn't think so.**

## Features

- LISP-style syntax
- Math primitives of `+` `*` and `-`
- Integers only, no floats
- Identifiers / variables
- No lambdas ... yet ?

## Requirements

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
