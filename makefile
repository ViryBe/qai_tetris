TARGET = tetris_player
SRC_DIR = src
BUILD_DIR = _build
MODULES = qlearn tetris
SOURCES = $(SRC_DIR)/$(MODULES:=.ml)
OBJS = $(SOURCES:.ml=.cmo)
OCAMLC = ocamlopt -g -I $(BUILD_DIR)
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
