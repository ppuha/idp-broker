let render_tmpl path data =
  let content = In_channel.with_open_text path (
    fun ic ->  In_channel.input_all ic
  ) in
  let tmpl = Mustache.of_string content in
  Mustache.render tmpl data
