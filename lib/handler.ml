open Lwt.Infix
open Dream

open Session

module Make
  (Client_store : Client.STORE)
  (Session_store : Session.STORE)
  (Token_store : Token.STORE) = struct

  let handle_auth req =
    let client_id = query req "client_id" |> Option.get in
    let redirect_uri = query req "redirect_uri" |> Option.get in
    Client_store.get client_id >>= function
    | Some client ->
      info (fun log -> log "client %s authenticated" client.client_id);
      let session = { client=client; code=Uuid.generate () } in
      let code = Session_store.insert session in
      let redirect_uri =
        Uri.add_query_param
          (Uri.of_string redirect_uri)
          ("code", [code |> Uuidm.to_string])
        |> Uri.to_string
      in
      redirect ~status:`Moved_Permanently req redirect_uri
    | None ->
      warning (fun log -> log "client %s not found " client_id);
      respond ~code:401 "unathorized"

  let form_value form key =
    List.find_opt (fun (k, _) -> k = key) form
    |> Option.map snd

  let session_of_form req =
    form ~csrf:false req >>= function
    | `Ok form ->
      let code = form_value form "code" |> Option.get in
      (Session_store.get (Uuidm.of_string code |> Option.get) >>= function
      | None -> Lwt.return None
      | Some session -> Some session |> Lwt.return)
    | _ -> Lwt.return None

  let handle_token req =
    let open Token in
    log "sessions: \n%s" (Session_store.dump ());
    session_of_form req >>= function
    | Some session ->
      let id = Uuid.generate () in
      let now = Unix.time () in
      let exp = now +. 10.0 in
      let token = {
        id=id;
        client_id=session.client.client_id;
        subject=session.client.client_id;
        issued_at=now |> int_of_float;
        expires_at=exp |> int_of_float;
      } in
      let _ = Token_store.insert token
      in
      `Assoc [
        "access_token", `String (Uuidm.to_string token.id);
        "exp", `Int (int_of_float exp)
      ]
      |> Yojson.Safe.to_string
      |> respond
    | None ->
      warning (fun log -> log "session not found");
      respond ~code:401 "unathorized"

  let routes = [
    get "/oauth2/auth" handle_auth;
    post "/oauth2/token" handle_token;
  ]
end
