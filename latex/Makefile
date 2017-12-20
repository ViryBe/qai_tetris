TARGET = report
PARAMEVAL = ../tetris_parameval.bash
CC = latexmk
FLAGS = -lualatex -shell-escape -synctex=1
GRAPHDIR = data
GRAPHS = gamma alphap
GRAPHFILES = $(addsuffix .dat, $(addprefix $(GRAPHDIR)/, $(GRAPHS)))
SRC = report.tex

$(TARGET): $(SRC) $(GRAPHFILES)
	$(CC) $(FLAGS) $<

$(GRAPHDIR)/gamma.dat:
	$(PARAMEVAL) -p gamma -l 0.8 -u 1 -n 6 -q -o $@
	sed -i '1s/^/%/' $@	# Comment first line containing param values

$(GRAPHDIR)/alphap.dat:
	$(PARAMEVAL) -p alphap -l 0.001 -u 0.005 -n 6 -q -o $@
	sed -i '1s/^/%/' $@

.PHONY: clean

clean:
	rm -rf *.log *.toc *.aux
