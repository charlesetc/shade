
(* example.ml *)

open Shade

module Redis = Redis_sync.Client

(* open a redis connection on start *)

let connection =
  let open Redis in
  Redis.connect {
  host = "127.0.0.1" ;
  port = 6379 ;
}

(* set redis keys based on json input *)

let set request =

  let set_key (key, value) = match value with
    | `String value -> ignore (Redis.set connection key value)
    | json -> raise (Shade_error ("incorrect type : should be a dictionary of strings", json))
  in
  match request.data with
    | `Assoc pairs -> List.iter set_key pairs ; `String "ok"
    | json -> raise (Shade_error ("incorrect type : should be a dictionary of strings", json))

(* get redis keys from a json string *)

let get request =
  match request.data with
  | `String key -> begin match Redis.get connection key with
    | Some str -> `String str
    | None -> `Null
    end
  | json -> raise (Shade_error ("incorrect type : string", json))


(* start the server with the given routes *)

let () =
  Shade.start [
    "/set", set ;
    "/get", get ;
  ]
