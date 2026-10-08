# IDP Broker

IDP Broker is an experimental OAuth 2.0 identity-provider broker written in
OCaml. It exposes a small set of authorization, token, and token-introspection
endpoints and is intended as a starting point for configurable identity
providers.

## Current status

This is a prototype, not a production-ready OAuth 2.0 server. The current
executable registers one in-memory demo client (`test-client`) and a static
identity provider. The demo provider's sample credentials are `foo` / `bar`,
but the form submission handler does not currently validate them. Client
authentication and redirect URI validation are also not implemented. Tokens,
clients, and sessions are kept only in memory, and access tokens are UUIDs
rather than signed tokens.

The UI template loader currently uses absolute development-machine paths, so
the identity-provider selection and login pages may not work outside the
original development environment without fixing those paths.

## Requirements

- OCaml
- Dune 3.17 or newer
- The OCaml libraries Dream, Lwt, Uuidm, Yojson, and Mustache

With opam, install the dependencies with:

```sh
opam install dune dream lwt uuidm yojson mustache
```

## Build and run

Build the project from its root directory:

```sh
dune build .
```

Run on port `5557`:

```sh
dune exec idp-broker -- -p 5557
```

The server defaults to port `8080` if `-p` is omitted. You can also use the
Makefile target to run locally on port `5557`:

```sh
make run-local
```

## Endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/oauth2/auth` | Starts an authorization session using `client_id` and `redirect_uri` query parameters. |
| `POST` | `/oauth2/auth` | Completes the demo authorization flow using a `session_id` form field and redirects with a code. |
| `POST` | `/oauth2/token` | Accepts a `code` form field and returns a JSON access token and expiration time. |
| `POST` | `/oauth2/introspect` | Accepts a `token` form field and returns token activity and claims as JSON. |
| `GET` | `/idp/select` | Displays the configured identity providers for a session. |
| `GET` | `/idp/auth` | Displays the static provider's login form. |

The in-memory demo client is `test-client`. The server currently adds
`Access-Control-Allow-Origin: *` to responses. These endpoints and behaviors
are experimental and should not be treated as a secure OAuth 2.0
implementation.

## Tests

Run the Dune test suite with:

```sh
dune runtest
```

## Docker

Build the image from the repository root and run it on the default port:

```sh
docker build -t idp-broker .
docker run --rm -p 8080:8080 idp-broker
```
