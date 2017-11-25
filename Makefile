TARGET = tetris_player
DOC_DIR = doc
CC = ocamlfind ocamlopt -g
PACKAGES = bolt
OCAMLC = $(CC) -package $(PACKAGES) -linkpkg
DOCGEN = ocamlfind ocamldoc -d $(DOC_DIR) -html
DEPGEN = ocamlfind ocamldep -package $(PACKAGES) -linkpkg
MODULES = agent game aio
SOURCES = $(MODULES:=.ml) main.ml
INTERFACES = $(MODULES:=.mli)
OBJS = $(MODULES:=.cmx)
CINT = $(MODULES:=.cmi)

all: .depend byte

byte: $(TARGET)

$(TARGET): $(CINT) $(OBJS) main.ml
	$(MAINCC) $(OBJS) main.ml -o $@

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
	$(DEPGEN) $^ > .depend

include .depend
