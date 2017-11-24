TARGET = tetris_player
DOC_DIR = doc
OCAMLC = ocamlopt -g
DOCGEN = ocamldoc -d $(DOC_DIR) -html
MODULES = agent game aio
SOURCES = $(MODULES:=.ml) main.ml
INTERFACES = $(MODULES:=.mli)
OBJS = $(MODULES:=.cmx)
CINT = $(MODULES:=.cmi)
DEP = ocamldep

all: .depend byte

byte: $(TARGET)

$(TARGET): $(CINT) $(OBJS) main.ml
	$(OCAMLC) $(OBJS) main.ml -o $@

%.cmi: %.mli
	$(OCAMLC) $<

%.cmx: %.ml
	$(OCAMLC) -c $<

doc: $(SOURCES) $(INTERFACES) $(CINT)
	$(DOCGEN) $(SOURCES) $(INTERFACES)

.PHONY: clean

clean:
	rm -f *.cm[xio] *.o *~

.depend: $(SOURCES) $(INTERFACES)
	$(DEP) $^ > .depend

include .depend
