ifeq ($(PANDOC_VERSION),2.6)
PANDOC_CITEPROC_COMMIT ?= 0.15.0.1
endif
ifeq ($(PANDOC_VERSION),2.7)
PANDOC_CITEPROC_COMMIT ?= 0.16.1.1
endif

# Use pandoc-citeproc master per default
PANDOC_CITEPROC_COMMIT ?= master
