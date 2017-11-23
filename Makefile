TARGET = tetris_player
DOC_DIR = doc
OCAMLC = ocamlopt -g
DOCGEN = ocamldoc -html -d $(DOC_DIR)
MODULES = agent game aio main
SOURCES = $(MODULES:=.ml)
OBJS = $(MODULES:=.cmx)
DEP = ocamldep

all: .depend byte

byte: $(TARGET)

$(TARGET): $(OBJS)
	$(OCAMLC) $^ -o $@

%.cmi: %.mli
	$(OCAMLC) $<

%.cmo: %.ml
	$(OCAMLC) -c $<

doc: $(SOURCES)
	$(DOCGEN) $<

.PHONY: clean

clean:
	rm -f *.cm[xio] *.o *~

.depend: $(SOURCES)
	$(DEP) *.mli *.ml > .depend

include .depend
