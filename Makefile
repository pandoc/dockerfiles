PANDOC_VERSION ?= edge

ifeq ($(PANDOC_VERSION),edge)
PANDOC_COMMIT          ?= master
PANDOC_CITEPROC_COMMIT ?= master
else
PANDOC_COMMIT          ?= $(PANDOC_VERSION)
PANDOC_CITEPROC_COMMIT ?= 0.15.0.1
endif

# Keep this target first so that `make` with no arguments will print this rather
# than potentially engaging in expensive builds.
.PHONY: show-args
show-args:
	@printf "PANDOC_VERSION (i.e. image version tag): %s\n" $(PANDOC_VERSION)
	@printf "pandoc_commit=%s\n" $(PANDOC_COMMIT)
	@printf "pandoc_citeproc_commit=%s\n" $(PANDOC_CITEPROC_COMMIT)

.PHONY: alpine alpine-tex
alpine:
	docker build \
	    --tag pandoc/core:$(PANDOC_VERSION) \
	    --build-arg pandoc_commit=$(PANDOC_COMMIT) \
	    --build-arg pandoc_citeproc_commit=$(PANDOC_CITEPROC_COMMIT) \
	    alpine/
alpine-tex:
	docker build \
	    --tag pandoc/alpine-tex:$(PANDOC_VERSION) \
	    --build-arg base_tag=$(PANDOC_VERSION) \
	    alpine/tex

