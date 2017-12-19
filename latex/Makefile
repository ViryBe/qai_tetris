TARGET = report
PARAMEVAL = ../tetris_parameval.bash
CC = latexmk
GRAPHDIR = data
GRAPHS = gamma alphap
GRAPHFILES = $(addsuffix .dat, $(addprefix $(GRAPHDIR)/, $(GRAPHS)))
SRC = report.tex

$(TARGET): $(SRC) $(GRAPHFILES)
	$(CC) $<

$(GRAPHDIR)/gamma.dat:
	$(PARAMEVAL) -p gamma -l 0.8 -u 1 -n 6 -o 'data/gamma.dat'

$(GRAPHDIR)/alphap.dat:
	$(PARAMEVAL) -p alphap -l 0.001 -u 0.005 -n 6 -o 'data/alphap.dat'

.PHONY: clean

clean:
	$(CC) -c
