FROM ocaml/opam:ubuntu-25.04-ocaml-4.10 AS builder

USER root

RUN apt-get update && \
    apt-get install -y pkg-config libev-dev libssl-dev

USER opam

RUN opam install -y dream lwt yojson uuidm

WORKDIR /home/opam/app

COPY --chown=opam . .

RUN opam exec -- dune build .

FROM ubuntu:25.04

RUN apt-get update && apt-get install -y libev4 libssl3

COPY --from=builder /home/opam/app/_build/default/bin/main.exe /app/idp

ENTRYPOINT [ "./app/idp" ]
