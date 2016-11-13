
# Shade

Shade is a simple json wrapper around an http server that's geared towards **easy** api's.

I made this because I wanted a way to quickly make  simple servers with ocaml that could easily interface with other languages.

## Usage

```ocaml
open Shade

(* this handler takes a request and returns a yojson json type *)
let is_a_string request =
  match request.data with
  | `String _ -> `String "Yes it's a string!"
  | data -> `Assoc [
    "message", `String "No that wasn't a string" ;
    "data", data
  ]

let () =
  Shade.start [
    "/is_a_string", is_a_string
  ]
```

Send this code a query with:

```bash
$ curl localhost:4000/is_a_string -d '{count: 2}'
{ "response": { "message": "No that wasn't a string", "data": {} } }
$ curl localhost:4000/is_a_string -d '"hi there!"'
{ "response": "Yes it's a string!" }
```

For a more complicated example check out "example.ml".

# Installation

Right now, this is not on opam. You do need [it](https://opam.ocaml.org/) set up though.

To install:

```bash
opam install ocaml-http yojson
git clone https://github.com/charlesetc/shade.git
cd shade
make install
```

## Warnings

Don't use global variables. The http daemon uses some kind of threading thing that screws them up. If you need a simple count you could do cookies (not yet implemented). Alternatively, there's an example using redis in ./example.ml.

## License

MIT
