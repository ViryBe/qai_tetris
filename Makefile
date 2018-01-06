TARGET = tetris_player
DOC_DIR = doc
BINDIR = bin
OCAMLCOPT = ocamlopt
OCAMLC = ocamlc -g
DOCGEN = ocamldoc -d $(DOC_DIR) -html
DEPGEN = ocamldep
TOPGEN = ocamlmktop
MODULES = game aio display agent
SOURCES = $(MODULES:=.ml) main.ml
INTERFACES = $(MODULES:=.mli)
OBJS = $(MODULES:=.cmo)
OBJSOPT = $(MODULES:=.cmx)
CINT = $(MODULES:=.cmi)
LIB = graphics unix

all: .depend byte opt top

byte: $(BINDIR)/$(TARGET)

opt: $(BINDIR)/$(TARGET).opt

top: $(BINDIR)/$(TARGET).top

$(BINDIR)/$(TARGET): $(CINT) $(OBJS) main.ml
	$(OCAMLC) $(LIB:=.cma) $(OBJS) main.ml -o $@

$(BINDIR)/$(TARGET).opt: $(CINT) $(OBJSOPT) main.ml
	$(OCAMLCOPT) $(LIB:=.cmxa) $(OBJSOPT) main.ml -o $@

$(BINDIR)/$(TARGET).top: $(OBJS)
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
	ctags *.ml *.mli *.bash Makefile

.depend: $(SOURCES) $(INTERFACES)
	$(DEPGEN) $^ > .depend

include .depend
