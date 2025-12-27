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

let is_expired token =
  let now = Unix.time () |> int_of_float in
  token.expires_at < now

let expired () =
  `Assoc [
    "active", `Bool false;
  ]

module type STORE = sig
  val get : Uuidm.t -> t option Lwt.t
  val insert : t -> Uuidm.t
  val dump : unit -> string
end

module Introspector (Store : STORE) = struct
  let introspect id =
    Store.get id >>= function
    | Some token -> claims token |> Lwt.return
    | None -> `Assoc [ "active", `Bool false ] |> Lwt.return
end
