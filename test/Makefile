PANDOC_VERSION ?= latest
CMD = docker run --rm -it -v $(PWD):/data pandoc/core:$(PANDOC_VERSION)

OUTPUT_FORMATS=markdown epub docx latex html

.PHONY: core-tests example-to-%

core-tests: $(foreach format,$(OUTPUT_FORMATS), example-to-$(format))

example-to-%: files/example.native
	$(CMD) $< --output=/dev/null --to=$*
