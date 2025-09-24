type t = {
  client : Client.t;
  code : Uuidm.t;
}

module type STORE = sig
  val get : Uuidm.t -> t option Lwt.t
  val insert : t -> Uuidm.t
end
