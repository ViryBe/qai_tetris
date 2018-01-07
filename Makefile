.PHONY: all clean byte native profile debug

OCB_FLAGS = -use-ocamlfind -tag bin_annot -I src
OCB = ocamlbuild $(OCB_FLAGS)

all: native byte profile

clean:
	$(OCB) -clean

native:
	$(OCB) main.native

byte:
	$(OCB) main.byte

profile:
	$(OCB) -tag profile main.native

debug:
	$(OCB) -tag debug main.byte
