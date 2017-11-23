TARGET = tetris_player
DOC_DIR = doc
OCAMLC = ocamlopt -g
DOCGEN = ocamldoc -html -d $(DOC_DIR)
MODULES = agent game aio
SOURCES = $(MODULES:=.ml)
INTERFACES = $(MODULES:=.mli)
OBJS = $(MODULES:=.cmx)
CINT = $(MODULES:=.cmi)
DEP = ocamldep

all: .depend byte

byte: $(TARGET)

$(TARGET): $(CINT) $(OBJS) main.ml
	$(OCAMLC) $^ -o $@

%.cmi: %.mli
	$(OCAMLC) $<

%.cmx: %.ml
	$(OCAMLC) -c $<

doc: $(SOURCES) $(INTERFACES)
	$(DOCGEN) $<

.PHONY: clean

clean:
	rm -f *.cm[xio] *.o *~

.depend: $(SOURCES)
	$(DEP) *.mli *.ml > .depend

include .depend
