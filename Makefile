TARGET = tetris_player
DOC_DIR = doc
MODULES = auxfct game aio display agent
SOURCES = $(MODULES:=.ml) main.ml
INTERFACES = $(MODULES:=.mli)
OBJS = $(MODULES:=.cmo)
OBJSOPT = $(MODULES:=.cmx)
CINT = $(MODULES:=.cmi)
LIB = graphics
# ocamlfind parameters
FINDLIBS = lacaml
OFIND_FLAGS = -package $(FINDLIBS) -linkpkg
# Build commands
OCAMLCOPT = ocamlfind ocamlopt $(OFIND_FLAGS)
OCAMLC = ocamlfind ocamlc -g $(OFIND_FLAGS)
DOCGEN = ocamlfind ocamldoc -d $(DOC_DIR) -html
DEPGEN = ocamlfind ocamldep
TOPGEN = ocamlfind ocamlmktop $(OFIND_FLAGS)

all: .depend byte opt top

byte: $(TARGET)

opt: $(TARGET).opt

top: $(TARGET).top

$(TARGET): $(CINT) $(OBJS) main.ml
	$(OCAMLC) $(LIB:=.cma) $(OBJS) main.ml -o $@

$(TARGET).opt: $(CINT) $(OBJSOPT) main.ml
	$(OCAMLCOPT) $(LIB:=.cmxa) $(OBJSOPT) main.ml -o $@

$(TARGET).top: $(OBJS)
	$(TOPGEN) $(LIB:=.cma) $^ -o $@

%.cmi: %.mli
	$(OCAMLC) -c $<

%.cmo: %.ml
	$(OCAMLC) -c $<

%.cmx: %.ml
	$(OCAMLCOPT) -c $<

doc: $(SOURCES) $(INTERFACES) $(CINT)
	$(DOCGEN) $(SOURCES) $(INTERFACES)

.PHONY: clean tags

clean:
	rm -f *.cm[xio] *.o *~

tags:
	ctags *.ml *.mli Makefile *.bash latex/*.tex

.depend: $(SOURCES) $(INTERFACES)
	$(DEPGEN) $^ > .depend

include .depend
