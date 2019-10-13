# Two primary targets are defined by this Makefile:
#
# 1. test-core: test a core base image
# 2. test-latex: test a latex image
#
# The IMAGE variable is required to be defined in order to `docker run` the
# various tests.  The parent Makefile test targets define this, or alternatively
#
# 1. IMAGE=pandoc/image:tag make test-core
# 2. IMAGE=pandoc/image:tag make test-latex
ifndef IMAGE
$(error IMAGE variable must be set to docker image to test)
endif

test_files_path := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: test
test: test-core test-latex

#   ____
#  / ___|___  _ __ ___
# | |   / _ \| '__/ _ \
# | |__| (_) | | |  __/
#  \____\___/|_|  \___|
#
CORE_CMD = docker run --rm -it -v $(test_files_path):/data $(IMAGE)
OUTPUT_FORMATS=markdown epub docx latex html

.PHONY: test-core testsuite-to-% test-bib-conversion test-lua
test-core: test-bib-conversion test-lua test-crossref \
		$(foreach format,$(OUTPUT_FORMATS), testsuite-to-$(format))

testsuite-to-%: testsuite.native
	@# Pure HTML cannot represent fractions, use supported math rendering method.
	$(CORE_CMD) $< --output=/dev/null --to=$* --mathml

test-bib-conversion: example.bib
	docker run --rm -it -v $(test_files_path):/data \
	    --entrypoint=/usr/local/bin/pandoc-citeproc $(IMAGE) \
	    --bib2yaml $< > /dev/null

test-lua: testsuite.native lpeg-test.lua
	docker run --rm -it -v $(test_files_path):/data $(IMAGE) \
	    --lua-filter=lpeg-test.lua --to=json --output=/dev/null $<

# TODO: create an actual test case
test-crossref:
	docker run --rm -it -v $(test_files_path):/data \
	    --entrypoint=/bin/sh $(IMAGE) \
	    pandoc-crossref --version

#  _         _____   __  __
# | |    __ |_   _|__\ \/ /
# | |   / _` || |/ _ \\  /
# | |__| (_| || |  __//  \
# |_____\__,_||_|\___/_/\_\
#
LATEX_CMD = docker run --rm -it \
	-v $(test_files_path):/data \
	$(IMAGE) \
	--fail-if-warnings

.PHONY: test-latex
test-latex: output/testsuite.pdf output/french.pdf output/german.pdf \
		output/lorem-geometry.pdf output/lorem-optional-packages.pdf \
		output/test-beamer.pdf output/test-natbib.pdf output/test-biblatex.pdf

output/testsuite.pdf: testsuite.native
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

output/test-natbib.pdf: test-beamer.md example.bib
	$(LATEX_CMD) $< \
	    --natbib \
	    --output=$@ \
	    --bibliography=example.bib \
	    --pdf-engine=xelatex

output/test-biblatex.tex: test-beamer.md
	$(LATEX_CMD) $< \
	    --biblatex \
	    --standalone \
	    --bibliography=example.bib \
	    --output=$@

output/example.bib: example.bib
	cp $< $@

output/baboon.png: baboon.png
	cp $< $@

output/test-biblatex.pdf: output/test-biblatex.tex output/example.bib \
		output/baboon.png
	docker run --rm -it -v $(test_files_path):/data \
	    --entrypoint=/data/pdf-via-biblatex.sh \
	    $(IMAGE) \
	    $(notdir $(basename $<))

#   ____ _
#  / ___| | ___  __ _ _ __
# | |   | |/ _ \/ _` | '_ \
# | |___| |  __/ (_| | | | |
#  \____|_|\___|\__,_|_| |_|
#
.PHONY: clean
clean:
	rm -rf output/*
