TARGET = tetris_player
DOC_DIR = doc
OCAMLC = ocamlopt -g
DOCGEN = ocamldoc -html -d $(DOC_DIR)
MODULES = agent game aio main
SOURCES = $(MODULES:=.ml)
OBJS = $(MODULES:=.cmo)
DEP = ocamldep

all: .depend byte

byte: $(TARGET)

$(TARGET): $(OBJS)
	$(OCAMLC) $^ -o $@

%.cmi: %.mli
	$(OCAMLC) $<

%.cmo: %.ml
	$(OCAMLC) -c $<

.PHONY: clean

clean:
	rm -f *.cm[io] *~

.depend: $(SOURCES)
	$(DEP) *.mli *.ml > .depend

include .depend
