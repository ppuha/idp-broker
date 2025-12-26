open Lwt.Infix

type t = {
  id : Uuidm.t;
  client_id : string;
  subject : string;
  issued_at : int;
  expires_at : int;
}

let claims token =
  `Assoc [
    "active", `Bool true;
    "client_id", `String token.client_id;
    "sub", `String token.subject;
    "iat", `Int token.issued_at;
    "exp", `Int token.expires_at;
  ]

module type STORE = sig
  val get : Uuidm.t -> t option Lwt.t
  val insert : t -> Uuidm.t
end

module Introspector (Store : STORE) = struct
  let introspect id =
    Store.get id >>= function
    | Some token -> claims token |> Lwt.return
    | None -> `Assoc [ "active", `Bool false ] |> Lwt.return
end
