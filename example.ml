
(* example.ml *)

let main request = 
  Shade.response ~text:"hi there!"

let () =
  Shade.start main
