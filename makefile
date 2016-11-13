
# makefile

# Testing relies on 'bats' which is a
# cool bash testing thing I found.
# These tests are very much integration
# tests.
test: build-example
	bats ./tests/test_example.bats

build:
	ocamlbuild -use-ocamlfind shade.cmo shade.cma shade.cmxa

build-example:
	ocamlbuild -use-ocamlfind -tags "package(redis.sync)" example.native


install: build
	ocamlfind install shade META _build/*

remove:
	ocamlfind remove shade
