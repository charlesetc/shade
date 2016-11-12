
(* shade.ml *)
open Http_types


type shade_response = {
  text : string
}

let response ?text:(text="") = 
  {text}

let convert_to_http callback request outchan =
  let text = (callback request).text in
  Http_daemon.respond ~body:text outchan 

let start main_callback =  
  let port = try 
    int_of_string (Sys.getenv "SHADE_PORT")
    with Not_found -> 4000
  in
  print_endline ("Listening on " ^ string_of_int port) ;
  Http_daemon.main { Http_daemon.default_spec with
    callback = convert_to_http main_callback ;
    port = port
  }

