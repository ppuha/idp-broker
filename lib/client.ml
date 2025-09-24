type t = {
  client_id : string;
  auth_method : auth_method;
}
and
auth_method =
  | Client_secret_post of string
  | Client_secret_basic of string
  | None

let valid_credentials _req auth_method =
  match auth_method with
  | Client_secret_post _secret -> true
  | Client_secret_basic _secret -> true
  | None -> true

module type STORE = sig
  val get : string -> t option Lwt.t
  val insert : t -> string
end

module Mock = struct
  let get id = Some { client_id=id; auth_method=None } |> Lwt.return
  let insert client = Some client.client_id |> Lwt.return
end
