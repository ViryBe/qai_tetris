# See https://github.com/ocaml/ocamlbuild/blob/master/examples/
DOCDIR = doc/qai_tetris.docdir
.PHONY: all clean byte native profile debug

OCB_FLAGS = -use-ocamlfind -tag bin_annot -I src
OCB = ocamlbuild $(OCB_FLAGS)

all: native byte

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

doc: doc_html doc_tex doc_texinfo doc_man

doc_html:
	$(OCB) $(DOCDIR)/index.html

doc_man:
	$(OCB) $(DOCDIR)/man

doc_tex:
	$(OCB) $(DOCDIR)/qai_tetris.tex

doc_texinfo:
	$(OCB) $(DOCDIR)/qai_tetris.texi

doc_dot:
	$(OCB) $(DOCDIR)/qai_tetris.dot

tags:
	ctags src/*.ml src/*.mli Makefile scripts/*.bash scripts/*.py *.bash
