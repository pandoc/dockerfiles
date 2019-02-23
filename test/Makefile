test_files_path := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
PANDOC_VERSION ?= latest

.PHONY: test
test: test-core test-latex

#   ____
#  / ___|___  _ __ ___
# | |   / _ \| '__/ _ \
# | |__| (_) | | |  __/
#  \____\___/|_|  \___|
#
CORE_CMD = docker run --rm -it -v $(test_files_path):/data pandoc/core:$(PANDOC_VERSION)
OUTPUT_FORMATS=markdown epub docx latex html

.PHONY: test-core example-to-%
test-core: $(foreach format,$(OUTPUT_FORMATS), example-to-$(format))

example-to-%: example.native
	$(CORE_CMD) $< --output=/dev/null --to=$*

#  _         _____   __  __
# | |    __ |_   _|__\ \/ /
# | |   / _` || |/ _ \\  /
# | |__| (_| || |  __//  \
# |_____\__,_||_|\___/_/\_\
#
LATEX_CMD = docker run --rm -it \
	-v $(test_files_path):/data \
	pandoc/latex:$(PANDOC_VERSION) \
	--fail-if-warnings

.PHONY: test-latex
test-latex: output/example.pdf output/french.pdf output/german.pdf \
		output/lorem-geometry.pdf output/lorem-optional-packages.pdf \
		output/test-beamer.pdf

output/example.pdf: example.native
	$(LATEX_CMD) $< \
	    --output=$@ \
	    --pdf-engine=xelatex

output/french.pdf: french.md
	$(LATEX_CMD) $< \
	    --output=$@ \
	    --pdf-engine=xelatex

output/german.pdf: german.md
	$(LATEX_CMD) $< \
	    --output=$@ \
	    --pdf-engine=xelatex

output/lorem-geometry.pdf: lorem.md geometry.yaml
	$(LATEX_CMD) $< \
	    --output=$@ \
	    --metadata-file=geometry.yaml \
	    --pdf-engine=xelatex

output/lorem-optional-packages.pdf: lorem.md optional-packages.yaml
	$(LATEX_CMD) $< \
	    optional-packages.yaml \
	    --output=$@ \
	    --pdf-engine=xelatex

output/test-beamer.pdf: test-beamer.md example.bib
	$(LATEX_CMD) $< \
	    --output=$@ \
	    --to=beamer \
	    --bibliography=example.bib \
	    --pdf-engine=xelatex

#   ____ _
#  / ___| | ___  __ _ _ __
# | |   | |/ _ \/ _` | '_ \
# | |___| |  __/ (_| | | | |
#  \____|_|\___|\__,_|_| |_|
#
.PHONY: clean
clean:
	rm -rf output/*
