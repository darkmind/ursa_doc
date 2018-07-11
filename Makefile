# Makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
BUILDDIR      = _build

# Internal variables.
ALLSPHINXOPTS   = -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .

all: html

clean: ; -rm -rf $(BUILDDIR)/*

html: ; $(SPHINXBUILD) -b html $(ALLSPHINXOPTS) $(BUILDDIR)/html ; echo ; echo "Build finished. The HTML pages are in $(BUILDDIR)/html"

.PHONY: clean html all