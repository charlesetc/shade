
# makefile

# Testing relies on 'bats' which is a
# cool bash testing thing I found.
# These tests are very much integration
# tests.
test: build
	bats ./tests/test_example.bats

build:
	ocamlbuild -use-ocamlfind example.native
