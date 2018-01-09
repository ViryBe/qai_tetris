PARAMEVAL = ../tetris_parameval.bash
LC = latexmk
FLAGS = -lualatex -shell-escape -synctex=1 -silent
GRAPHDIR = data
GRAPHS = gamma gamma_wide alphap alphap_wide epsilon epsilon_wide
GRAPHFILES = $(addsuffix .dat, $(addprefix $(GRAPHDIR)/, $(GRAPHS)))

all: report.pdf slideshow.pdf

slideshow.pdf: slideshow.tex
	$(LC) $(FLAGS) $<

report.pdf: report.tex $(GRAPHFILES)
	$(LC) $(FLAGS) $<

$(GRAPHDIR)/gamma_wide.dat:
	$(PARAMEVAL) -p gamma -l 0.6 -u 0.9 -n 3 -q -o $@
	sed -i '1s/^/%/' $@

$(GRAPHDIR)/gamma.dat:
	$(PARAMEVAL) -p gamma -l 0.8 -u 1 -n 4 -q -o $@
	sed -i '1s/^/%/' $@	# Comment first line containing param values

$(GRAPHDIR)/alphap.dat:
	$(PARAMEVAL) -p alphap -l 0.001 -u 0.003 -n 4 -q -o $@
	sed -i '1s/^/%/' $@

$(GRAPHDIR)/alphap_wide.dat:
	$(PARAMEVAL) -p alphap -l 0.001 -u 0.3 -n 3 -q -o $@
	sed -i '1s/^/%/' $@

$(GRAPHDIR)/epsilon.dat:
	$(PARAMEVAL) -p epsilon -l 0 -u 0.003 -n 4 -q -o $@
	sed -i '1s/^/%/' $@

$(GRAPHDIR)/epsilon_wide.dat:
	$(PARAMEVAL) -p epsilon -l 0.002 -u 0.2 -n 4 -q -o $@
	sed -i '1s/^/%/' $@

.PHONY: clean tags

tags:
	ctags *.tex Makefile

clean:
	$(LC) -c
	rm -f data/*.dat
