open Idp_broker.Server

let () =
  let port = ref 8080 in
  let usage_msg = "-p port" in
  let speclist = [
    ("-p", Arg.Int (fun p -> port := p), "Port to run on");
  ] in
  let anon_fun _ = () in
  Arg.parse speclist anon_fun usage_msg;
  run_server !port
