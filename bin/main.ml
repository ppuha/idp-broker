open Lwt.Infix

open Idp

let cors (handler : Dream.handler) =
  fun req ->
    handler req >>= fun resp ->
    Dream.add_header resp "Access-Control-Allow-Origin" "*";
    resp |> Lwt.return

let run_server () =
  Dream.router [
    Dream.scope "/" [cors] Config.H.routes
  ]
  |> Dream.logger 
  |> Dream.run ~port:5556 ~error_handler:Dream.debug_error_handler

let () = run_server ()
