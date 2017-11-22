TARGET = tetris_player
SRC_DIR = src
BUILD_DIR = _build
DOC_DIR = doc
OCAMLC = ocamlopt -g -I $(BUILD_DIR)
DOCGEN = ocamldoc -html -d $(DOC_DIR)
MODULES = qlearn tetris
SOURCES = $(SRC_DIR)/$(MODULES:=.ml)
OBJS = $(BUILD_DIR)/$(MODULES:=.cmo)
DEP = ocamldep

all: .depend byte

byte: $(TARGET)

$(TARGET): $(OBJS)
	$(OCAMLC) -o $(BUILD_DIR)/$@ $^

%.cmi: %.mli
	$(OCAMLC) $<

%.cmo: %.ml
	$(OCAMLC) -c $<

.PHONY: clean

clean:
	rm -f SRC_DIR/*.cm[io] *~

.depend: $(SOURCES)
	$(DEP) *.mli *.ml > .depend

include .depend
