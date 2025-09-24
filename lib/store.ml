module type CONTENT = sig
  type id
  type entry
  val get_id : entry -> id
end

module Inmem_store (C : CONTENT) = struct
  let entries = ref []

  let get (id : C.id) : C.entry option Lwt.t =
    List.find_opt (fun entry -> C.get_id entry = id) !entries
    |> Lwt.return

  let insert (entry : C.entry) : C.id =
    entries := (entry :: !entries);
    C.get_id entry
end
