module Client_store = Store.Inmem_store (struct
  open Client
  type entry = t
  type id = string
  let get_id client = client.client_id
  let to_string client = client.client_id
end)
let _ = Client_store.insert {
  client_id="test-client";
  auth_method=None;
}

module Session_store = Store.Inmem_store (struct
  open Session
  type entry = t
  type id = Uuidm.t
  let get_id session = session.code
  let to_string session = session.code |> Uuidm.to_string
end)

module Token_store = Store.Inmem_store (struct
  open Token
  type id = Uuidm.t
  type entry = t
  let get_id token = token.id
  let to_string token = token.id |> Uuidm.to_string
end)

module H = Handler.Make (Client_store) (Session_store) (Token_store)
