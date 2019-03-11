PANDOC_VERSION ?= edge

ifeq ($(PANDOC_VERSION),edge)
PANDOC_COMMIT          ?= master
else
PANDOC_COMMIT          ?= $(PANDOC_VERSION)
endif

# Used to specify the build context path for Docker.  Note that we are
# specifying the repository root so that we can
#
#     COPY latex-common/texlive.profile /root
#
# for example.  If writing a COPY statement in *ANY* Dockerfile, just know that
# it is from the repository root.
makefile_dir := $(dir $(realpath Makefile))

# Keep this target first so that `make` with no arguments will print this rather
# than potentially engaging in expensive builds.
.PHONY: show-args
show-args:
	@printf "PANDOC_VERSION (i.e. image version tag): %s\n" $(PANDOC_VERSION)
	@printf "pandoc_commit=%s\n" $(PANDOC_COMMIT)

################################################################################
# Alpine images and tests                                                      #
################################################################################
.PHONY: alpine alpine-latex test-alpine test-alpine-latex
alpine:
	docker build \
	    --tag pandoc/core:$(PANDOC_VERSION) \
	    --build-arg pandoc_commit=$(PANDOC_COMMIT) \
	    -f $(makefile_dir)/alpine/Dockerfile $(makefile_dir)
alpine-latex:
	docker build \
	    --tag pandoc/latex:$(PANDOC_VERSION) \
	    --build-arg base_tag=$(PANDOC_VERSION) \
	    -f $(makefile_dir)/alpine/latex/Dockerfile $(makefile_dir)
test-alpine: IMAGE ?= pandoc/core:$(PANDOC_VERSION)
test-alpine:
	IMAGE=$(IMAGE) make -C test test-core
test-alpine-latex: IMAGE ?= pandoc/latex:$(PANDOC_VERSION)
test-alpine-latex:
	IMAGE=$(IMAGE) make -C test test-latex

################################################################################
# Developer targets                                                            #
################################################################################
.PHONY: lint
lint:
	shellcheck $(shell find . -name "*.sh")

.PHONY: clean
clean:
	IMAGE=none make -C test clean
