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

# Yearly archiving for tex: https://github.com/pandoc/dockerfiles/issues/43
# Base image, archive year required args.
#
#   BASE_IMAGE: "latex" for alpine, otherwise e.g., "ubuntu-latex"
#   ARCHIVE_YEAR: "2019" (example).
#
# Example: make archive BASE_IMAGE=latex ARCHIVE_YEAR=2019 PANDOC_VERSION=2.6
# Archives pandoc/latex:2.6 with 2019 tlmgr url, tagging as pandoc/latex:2.6
# to allow you to repush online.
BASE_IMAGE :=
ARCHIVE_YEAR :=

# NOTE: this is an awkward way to check for both of these, but it's late
# and I'm writing Make...so i'll take what works.
err_archive = BASE_IMAGE and ARCHIVE_YEAR required arguments
.PHONY: archive
ifneq ($(BASE_IMAGE),)
ifneq ($(ARCHIVE_YEAR),)
archive:
	@# NOTE: it's going to pull e.g., pandoc/latex:tag down during the build
	@# which we will then basically overwrite.
	docker build \
		--tag pandoc/$(BASE_IMAGE):$(PANDOC_VERSION)-archived \
		--build-arg base_image=$(BASE_IMAGE) \
		--build-arg archive_year=$(ARCHIVE_YEAR) \
		--build-arg base_tag=$(PANDOC_VERSION) \
	    -f $(makefile_dir)/common/latex/archive/Dockerfile $(makefile_dir)
	@# Image downloaded and built as ${orig}-archived:${tag}, name swap.
	docker image tag \
		pandoc/$(BASE_IMAGE):$(PANDOC_VERSION) \
		pandoc/$(BASE_IMAGE):$(PANDOC_VERSION)-old
	docker image tag \
		pandoc/$(BASE_IMAGE):$(PANDOC_VERSION)-archived \
		pandoc/$(BASE_IMAGE):$(PANDOC_VERSION)
	@# With names swapped, test tlmgr works to report success or fail.
	docker build \
		--tag pandoc/$(BASE_IMAGE):$(PANDOC_VERSION)-test-archive \
		--build-arg base_image=$(BASE_IMAGE) \
	    --build-arg base_tag=$(PANDOC_VERSION) \
		-f $(makefile_dir)/common/latex/archive/test-archive/Dockerfile $(makefile_dir)
else
archive:
	$(error $(err_archive))
endif
else
archive:
	$(error $(err_archive))
endif
