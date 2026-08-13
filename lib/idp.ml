module type IDP = sig
  val name : string
  type auth_params
  type auth_result
  type auth_error

  val auth_url : Uuidm.t -> Uri.t
  val authenticate : auth_params -> (auth_result, auth_error) Result.t
end

module Static = struct
  let name = "static"
  type auth_params = string * string
  type auth_result = bool
  type auth_error = string

  let auth_url session_id = Printf.sprintf "/idp/auth?session=%s" (session_id |> Uuidm.to_string) |> Uri.of_string
  let authenticate (username, password)=
    if username = "foo" && password = "bar"
      then Ok(true)
      else Error("unathorized")
end

module type CONFIG = sig
  val idps : (module IDP) list
end
