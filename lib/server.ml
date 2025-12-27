open Lwt.Infix
open Dream

let cors handler  =
  fun req ->
    handler req >>= fun resp ->
    add_header resp "Access-Control-Allow-Origin" "*";
    resp |> Lwt.return

let run_server port =
  router [
    scope "/" [cors] Config.H.routes
  ]
  |> logger
  |> run ~port ~error_handler:debug_error_handler
