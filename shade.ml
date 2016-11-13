
(* shade.ml *)
open Http_types

type shade_response = {
  text : string
}

type shade_request = {
  data : Yojson.Basic.json ;
  uri : string ;
  sections : string list ;
}

exception Shade_error of string * Yojson.Basic.json

let sections uri =
  Str.split (Str.regexp "/") uri


let convert_to_shade callback request outchan =
  let json = try if request#body = "" then
    raise (Shade_error ("not json", `String "Please input json to a shade server"))
  else
    let request = {
      data = Yojson.Basic.from_string request#body ;
      uri = request#uri ;
      sections = sections (request#uri) ;
    } in
    `Assoc [
      "response", (callback request)
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

let first_uri_section request =
  "/" ^ try List.nth request.sections 0 with _ -> "";;

let rec aggregated_callback routes request =
  match routes with
  | (uri, callback)::routes ->
      if uri = first_uri_section request then
        let request = request in
        callback request
      else aggregated_callback routes request
  | [] -> raise Not_found

let start routes =
  let port = try 
    int_of_string (Sys.getenv "SHADE_PORT")
    with Not_found -> 4000
  in
  print_endline ("Listening on " ^ string_of_int port) ;
  Http_daemon.main { Http_daemon.default_spec with
    callback = routes |> aggregated_callback |> convert_to_shade ;
    port = port
  }

