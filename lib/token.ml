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
  val get : int -> t option Lwt.t
end

module Store = Store.Inmem_store (struct
  type id = int
  type entry = t
  let get_id token = token.issued_at
  let to_string token = token.id |> Uuidm.to_string
end)

module Introspector (Store : STORE) = struct
  let introspect id =
    Store.get id >>= function
    | Some token -> claims token |> Lwt.return
    | None -> `Assoc [ "active", `Bool false ] |> Lwt.return
end
