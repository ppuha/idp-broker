module type S = sig
  type context
  type auth_params
  type auth_result
  type auth_error

  val auth_url : context -> Uri.t
  val authenticate : auth_params -> (auth_result, auth_error) Result.t
end

module Static = struct
  type context = string * Uri.t
  type auth_params = string
  type auth_result = bool
  type auth_error = string

  let auth_url (_, context) = context
  let authenticate client_id =
    if client_id = "test-client"
      then Ok(true)
    else Ok(false)
end
