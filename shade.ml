
(* shade.ml *)
open Http_types

type shade_response = {
  text : string
}

type shade_request = {
  data : Yojson.Basic.json
}

exception Shade_error of string * Yojson.Basic.json

let convert_to_shade callback request outchan =
  let json = try if request#body = "" then
    raise (Shade_error ("not json", `String "Please input json to a shade server"))
  else
    `Assoc [
      "data", (callback {data = Yojson.Basic.from_string request#body})
    ]
  with
    |Shade_error (message, error_data) ->
    `Assoc [
      "error", `String message;
      "error_data", error_data;
    ]
    | other ->
    `Assoc [
      "error", `String (Printexc.to_string other);
    ]
  in
  let text = Yojson.Basic.to_string json in
  let text = Yojson.Basic.prettify text ^ "\n" in
  Http_daemon.respond ~body:text outchan 

let start (main_callback : shade_request -> Yojson.Basic.json) =
  let port = try 
    int_of_string (Sys.getenv "SHADE_PORT")
    with Not_found -> 4000
  in
  print_endline ("Listening on " ^ string_of_int port) ;
  Http_daemon.main { Http_daemon.default_spec with
    callback = convert_to_shade main_callback ;
    port = port
  }

