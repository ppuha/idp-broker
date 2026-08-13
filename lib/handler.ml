open Lwt.Infix
open Dream

open Session
open Render
open Util

module Make
  (Client_store : Client.STORE)
  (Session_store : Session.STORE)
  (Token_store : Token.STORE)
  (Idp_config : Idp.CONFIG) = struct

  let select_handler req =
    let session_id =
      query req "session" |> Option.get
      |> Uuidm.of_string |> Option.get
    in
    render_tmpl "/users/peterpuha/code/ml/idp/web/select.mustache" (
      `O [
        "idps",
        `A (
          Idp_config.idps
          |> List.map (fun (module I : Idp.IDP) ->
            `O [
              ("name", `String I.name);
              ("url", `String (I.auth_url session_id |> Uri.to_string));
            ]
        ))
      ]) |> Dream.html

  let static_handler req =
    let session_id = Dream.query req "session" |> Option.get in
    render_tmpl "/users/peterpuha/code/ml/idp/web/login.mustache" (`O [
      "session_id", `String session_id;
    ]) |> Dream.html

  let handle_auth_get req =
    let client_id = query req "client_id" |> Option.get in
    let redirect_uri = query req "redirect_uri" |> Option.get in
    Client_store.get client_id >>= function
    | None ->
      warning (fun log -> log "client %s not found " client_id);
      respond ~code:401 "unathorized"
    | Some client ->
      info (fun log -> log "client %s authenticated" client.client_id);
      let session = {
        id=Uuid.generate ();
        client=client;
        redirect_uri=redirect_uri;
        code=Uuid.generate ()
      } in
      let session_id = Session_store.insert session in
      redirect req (Printf.sprintf "/idp/select?session=%s" (session_id |> Uuidm.to_string))

  let handle_auth_post req =
    form ~csrf:false req >>= function
      | `Ok form ->
        (match form_value form "session_id" with
        | Some session_id ->
          (Session_store.get (Uuidm.of_string session_id |> Option.get) >>= fun session_opt ->
          match session_opt with
          | None -> respond ~code:404 (Printf.sprintf "no session with id %s was found" session_id)
          | Some session ->
            let redirect_uri = redirect_uri_with_code session.redirect_uri session.code in
            redirect
              ~status:`Moved_Permanently
              req
              redirect_uri)
        | _ -> respond ~code:500 "bad form")
      | _ -> respond ~code:500 "bad form"

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
    | None ->
      warning (fun log -> log "session not found");
      respond ~code:401 "unathorized"
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

  let token_of_form req =
    form ~csrf:false req >>= function
    | `Ok form ->
      let token = form_value form "token" |> Option.get in
      Uuidm.of_string token
      |> Option.get
      |> Token_store.get >>= Lwt.return
    | _ -> Lwt.return None

  let handle_introspect req =
    let open Token in
    token_of_form req >>= fun token ->
    let resp = match token with
    | Some token ->
      (if is_expired token then expired ()
      else claims token)
    | None ->
      expired ()
    in
    Yojson.Safe.to_string resp |> respond

  let routes = [
    get "/oauth2/auth" handle_auth_get;
    post "/oauth2/auth" handle_auth_post;
    post "/oauth2/token" handle_token;
    post "/oauth2/introspect" handle_introspect;
    get "/idp/auth" static_handler;
    get "/idp/select" select_handler;
  ]
end
