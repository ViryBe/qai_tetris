TARGET = tetris_player
DOC_DIR = doc
OCAMLCOPT = ocamlopt
OCAMLC = ocamlc -g
DOCGEN = ocamldoc -d $(DOC_DIR) -html
DEPGEN = ocamldep
TOPGEN = ocamlmktop
MODULES = game aio agent
SOURCES = $(MODULES:=.ml) main.ml
INTERFACES = $(MODULES:=.mli)
OBJS = $(MODULES:=.cmo)
OBJSOPT = $(MODULES:=.cmx)
CINT = $(MODULES:=.cmi)

all: .depend byte opt top

byte: $(TARGET)

opt: $(TARGET).opt

top: $(TARGET).top

$(TARGET): $(CINT) $(OBJS) main.ml
	$(OCAMLC) $(OBJS) main.ml -o $@

$(TARGET).opt: $(CINT) $(OBJSOPT) main.ml
	$(OCAMLCOPT) $(OBJSOPT) main.ml -o $@

$(TARGET).top: $(OBJS)
	$(TOPGEN) $^ -o $@

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
	otags -vi *.ml *.mli

.depend: $(SOURCES) $(INTERFACES)
	$(DEPGEN) $^ > .depend

include .depend
