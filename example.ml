
(* example.ml *)

open Shade

let main request = 
  request.data

let () =
  Shade.start main
