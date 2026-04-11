build:
	dune build .

run-local:
	dune exec idp-broker -- -p 5557
