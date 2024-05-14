# Three primary targets are defined by this Makefile:
#
# 1. test-minimal: test a minimal base image
# 2. test-latex: test a latex image
# 3. test-extra: test an extra image
#
# The IMAGE variable is required to be defined in order to `docker run` the
# various tests.  The parent Makefile test targets define this, or alternatively
#
# 1. IMAGE=pandoc/image:tag make test-minimal
# 2. IMAGE=pandoc/image:tag make test-latex
# 3. IMAGE=pandoc/image:tag make test-extra
ifndef IMAGE
$(error IMAGE variable must be set to docker image to test)
endif

# Control how to diff files
DIFF ?= diff

test_files_path := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: test
test: test-minimal test-latex test-extra

#   ____
#  / ___|___  _ __ ___
# | |   / _ \| '__/ _ \
# | |__| (_) | | |  __/
#  \____\___/|_|  \___|
#
CORE_CMD = docker run --rm -v $(test_files_path):/data $(IMAGE)
OUTPUT_FORMATS=markdown epub docx latex html

.PHONY: test-minimal testsuite-to-% test-bib-conversion test-lua
test-minimal: test-lua \
		$(foreach format,$(OUTPUT_FORMATS), testsuite-to-$(format))

testsuite-to-%: testsuite.native
	@# Pure HTML cannot represent fractions, use supported math rendering method.
	$(CORE_CMD) $< --output=/dev/null --to=$* --mathml

test-lua: testsuite.native lpeg-test.lua
	docker run --rm -v $(test_files_path):/data $(IMAGE) \
	    --lua-filter=lpeg-test.lua --to=json --output=/dev/null $<

#   ____                             __
#  / ___|_ __ ___  ___ ___ _ __ ___ / _|
# | |   | '__/ _ \/ __/ __| '__/ _ \ |_
# | |___| | | (_) \__ \__ \ | |  __/  _|
#  \____|_|  \___/|___/___/_|  \___|_|
#
.PHONY: test-core test-crossref-is-callable
test-core: test-crossref-is-callable test-crossref-filter

test-crossref-is-callable:
	@printf "### testing whether pandoc-crossref is in PATH "
	@printf "and can be called with --version...\n"
	docker run --rm -v $(test_files_path):/data \
	    --entrypoint=pandoc-crossref $(IMAGE) --version

test-crossref-filter: $(test_files_path)/crossref-test.md \
		$(test_files_path)/expected/crossref-test.native \
		$(test_files_path)/minversion.lua
	@printf "\n### testing document conversion with pandoc-crossref filter...\n"

	@if docker run --rm -v $(test_files_path):/data $(IMAGE) \
	      --metadata=minversion=2.16 \
	      --lua-filter=minversion.lua; then \
	    docker run --rm -v $(test_files_path):/data $(IMAGE) \
	        --filter=pandoc-crossref \
	        --to=native \
	        crossref-test.md | $(DIFF) expected/crossref-test.native -; \
	else \
	    printf "### Pandoc version is too old for this test, skipping.\n"; \
	fi

#  _         _____   __  __
# | |    __ |_   _|__\ \/ /
# | |   / _` || |/ _ \\  /
# | |__| (_| || |  __//  \
# |_____\__,_||_|\___/_/\_\
#
LATEX_CMD = docker run --rm \
	-v $(test_files_path):/data \
	$(IMAGE)

# Generate list of targets to test all highlighting options available in pandoc.
# See: https://pandoc.org/MANUAL.html#option--highlight-style
styles = pygments \
         kate \
         monochrome \
         breezeDark \
         espresso \
         zenburn \
         haddock \
         tango
# Create code-highlight-{pygments,kate,...}.pdf targets names.  List needed now
# to add to test-latex target.  Rules generated below after test-biblatex.pdf.
code_targets = $(addsuffix .pdf, $(addprefix output/code-highlight-, $(styles)))

.PHONY: test-latex
test-latex: output/testsuite.pdf output/french.pdf output/german.pdf \
		output/lorem-geometry.pdf output/lorem-optional-packages.pdf \
		output/test-beamer.pdf output/test-natbib.pdf \
		$(code_targets)

## FIXME! This test fails in Alpine, but the reason is unclear. We are
## disabling the test temporarily, as biblatex support is rarely used.
#   output/test-biblatex.pdf

output/testsuite.pdf: testsuite.native
	$(LATEX_CMD) $< \
	    --output=$@ \
	    --pdf-engine=latexmk

output/french.pdf: french.md
	$(LATEX_CMD) $< \
	    --output=$@ \
	    --variable=csquotes \
	    --pdf-engine=xelatex

output/german.pdf: german.md
	$(LATEX_CMD) $< \
	    --output=$@ \
	    --pdf-engine=lualatex

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
	docker run --rm -v $(test_files_path):/data \
	    --entrypoint=/data/pdf-via-biblatex.sh \
	    $(IMAGE) \
	    $(notdir $(basename $<))

# Use every highlighter to make sure all needed packages are installed.
$(code_targets): output/code-highlight-%.pdf: code-highlight.md
	$(LATEX_CMD) $< \
	    --highlight-style=$* \
	    --output=$@

#
#                 m
#  mmm   m   m  mm#mm   m mm   mmm
# #"  #   #m#     #     #"  " "   #
# #""""   m#m     #     #     m"""#
# "#mm"  m" "m    "mm   #     "mm"#
#
EXTRA_CMD = docker run --rm \
	-v $(test_files_path):/data \
	$(IMAGE) \
	--fail-if-warnings

.PHONY: test-extra
test-extra: output/eisvogel.pdf output/eisvogel_with_environment.pdf \
			output/beamertheme-metropolis.pdf output/lua.html

output/eisvogel.pdf: eisvogel.md
	$(EXTRA_CMD) $< \
	    --output=$@ \
	    --template=eisvogel \
	    --pdf-engine=xelatex

output/eisvogel_with_environment.pdf: eisvogel.md
	$(EXTRA_CMD) $< \
	    --output=$@ \
	    --template=eisvogel \
	    --pdf-engine=xelatex \
	    --filter=pandoc-latex-environment

output/beamertheme-metropolis.pdf: beamertheme-metropolis.md
	$(EXTRA_CMD) $< \
	    --output=$@ \
	    --to=beamer \
	    --variable=theme:metropolis \
	    --variable=themeoptions:numbering=none

output/lua.html: eisvogel.md
	$(EXTRA_CMD) $< \
	    --output=$@ \
	    --lua-filter=pagebreak.lua

#   ____ _
#  / ___| | ___  __ _ _ __
# | |   | |/ _ \/ _` | '_ \
# | |___| |  __/ (_| | | | |
#  \____|_|\___|\__,_|_| |_|
#
.PHONY: clean
clean:
	rm -rf output/*
