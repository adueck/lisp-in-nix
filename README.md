# LISP in Nix

I wanted to learn the Nix language. I heard that that Nix was Turing-complete, so I wrote a little LISP-style calculator in it. This is written done purely in this language people use for configuration, using only [builtins](https://nix.dev/manual/nix/2.18/language/builtins). **Can YAML do that? I didn't think so.**

## Features

- LISP-style polish notation
- Math primitives of `+` `*` and `-`
- Integers only, no floats
- No variables or lambdas ... yet ?

## System Requirements

- Nix

## Running the calculator

Edit `source.lisp`, to contain something one expression you want to evaluate, like:

```lisp
(+
    (* 10 3)
    5
    (- 3 1 1))
```

Run `nix-instantiate --eval` to evaluate the source.

```bash
$ nix-instantiate --eval
36
```
