module type CONTENT = sig
  type id
  type entry
  val get_id : entry -> id
  val to_string : entry -> string
end

module Inmem_store (C : CONTENT) = struct
  let entries = ref []

  let get (id : C.id) : C.entry option Lwt.t =
    List.find_opt (fun entry -> C.get_id entry = id) !entries
    |> Lwt.return

  let insert (entry : C.entry) : C.id =
    entries := (entry :: !entries);
    C.get_id entry

  let dump () = (!entries) |> List.map C.to_string |> String.concat "\n"
end
