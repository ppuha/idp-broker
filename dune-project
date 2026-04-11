(lang dune 3.17)

(name idp-broker)

(generate_opam_files true)

(source
 (github ppuha/idp-broker))

(authors "Péter Puha <ppuhap87@gmail.com>")

(maintainers "Péter Puha <ppuhap87@gmail.com>")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name idp-broker)
 (synopsis "IDP broker library and server")
 (description "An OAuth2 IDP broker configurable by code")
 (depends ocaml)
 (tags
  ("oauth2" "broker" "h2m")))
