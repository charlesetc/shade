
(* example.ml *)

open Shade

module Redis = Redis_sync.Client

let connection =
  let open Redis in
  Redis.connect {
  host = "127.0.0.1" ;
  port = 6379 ;
}

let set request =

  let set_key (key, value) = match value with
    | `String value -> ignore (Redis.set connection key value)
    | json -> raise (Shade_error ("incorrect type : should be a dictionary of strings", json))
  in

  let () = match request.data with
    | `Assoc pairs -> List.iter set_key pairs
    | json -> raise (Shade_error ("incorrect type : should be a dictionary of strings", json))
  in
  `String "ok"

let get request =
  match request.data with
  | `String key -> begin match Redis.get connection key with
    | Some str -> `String str
    | None -> `Null
    end
  | json -> raise (Shade_error ("incorrect type : string", json))

let () =
  Shade.start [
    "/set", set ;
    "/get", get ;
  ]
