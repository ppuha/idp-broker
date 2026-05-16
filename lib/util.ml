let form_value form key =
  List.find_opt (fun (k, _) -> k = key) form
  |> Option.map snd

let redirect_uri_with_code redirect_uri code =
  Uri.add_query_param
    (Uri.of_string redirect_uri)
    ("code", [code |> Uuidm.to_string])
  |> Uri.to_string
