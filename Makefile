TARGET = tetris_player
DOC_DIR = doc
CCOPT = ocamlfind ocamlopt -g
CC = ocamlfind ocamlc -g
PACKAGES = bolt
OCAMLCOPT = $(CCOPT) -package $(PACKAGES) -linkpkg
OCAMLC = $(CC) -package $(PACKAGES) -linkpkg
DOCGEN = ocamlfind ocamldoc -package $(PACKAGES) -d $(DOC_DIR) -html
DEPGEN = ocamlfind ocamldep -package $(PACKAGES)
TOPGEN = ocamlfind ocamlmktop -package $(PACKAGES) -linkpkg
MODULES = game aio agent
SOURCES = $(MODULES:=.ml) main.ml
INTERFACES = $(MODULES:=.mli)
OBJS = $(MODULES:=.cmo)
OBJSOPT = $(MODULES:=.cmx)
CINT = $(MODULES:=.cmi)

all: .depend byte opt

byte: $(TARGET)

opt: $(TARGET).opt

$(TARGET): $(CINT) $(OBJS) main.ml
	$(OCAMLC) $(OBJS) main.ml -o $@

$(TARGET).opt: $(CINT) $(OBJSOPT) main.ml
	$(OCAMLCOPT) $(OBJSOPT) main.ml -o $@

%.cmi: %.mli
	$(OCAMLC) $<

%.cmo: %.ml
	$(OCAMLC) -c $<

%.cmx: %.ml
	$(OCAMLCOPT) -c $<

doc: $(SOURCES) $(INTERFACES) $(CINT)
	$(DOCGEN) $(SOURCES) $(INTERFACES)

top: $(OBJS)
	$(TOPGEN) $^

.PHONY: clean tags

clean:
	rm -f *.cm[xio] *.o *~

tags:
	otags -vi *.ml *.mli

.depend: $(SOURCES) $(INTERFACES)
	$(DEPGEN) $^ > .depend

include .depend
