type t = {
  id : Uuidm.t;
  client : Client.t;
  redirect_uri : string;
  code : Uuidm.t;
}

module type STORE = sig
  val get : Uuidm.t -> t option Lwt.t
  val insert : t -> Uuidm.t
  val dump : unit -> string
end
