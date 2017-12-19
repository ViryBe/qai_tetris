TARGET = report
PARAMEVAL = ../tetris_parameval.bash
CC = latexmk
GRAPHDIR = data
GRAPHS = gamma
GRAPHFILES = $(GRAPHDIR)/$(GRAPHS:=.dat)
SRC = report.tex

$(TARGET): $(SRC) $(GRAPHFILES)
	$(CC) $<

$(GRAPHDIR)/gamma.dat:
	$(PARAMEVAL) -p gamma -l 0.8 -u 1 -n 6 -o 'latex/data/gamma.dat'

.PHONY: clean

clean:
	$(CC) -c
