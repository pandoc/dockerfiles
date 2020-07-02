PANDOC_VERSION ?= edge

ifeq ($(PANDOC_VERSION),edge)
PANDOC_COMMIT          ?= master
else
PANDOC_COMMIT          ?= $(PANDOC_VERSION)
endif

# Variable controlling whether pandoc-crossref should not be included in
# the image. Useful when building new pandoc versions for which there is
# no compatible pandoc-crossref version available. Setting this to a
# non-empty string prevents pandoc-crossref from being built.
WITHOUT_CROSSREF ?=

# Use Alpine Linux as base stack by default.
STACK ?= alpine

# Used to specify the build context path for Docker.  Note that we are
# specifying the repository root so that we can
#
#     COPY common/latex/texlive.profile /root
#
# for example.  If writing a COPY statement in *ANY* Dockerfile, just know that
# it is from the repository root.
makefile_dir := $(dir $(realpath Makefile))

# The freeze file fixes the versions of Haskell packages used to compile a
# specific version. This enables reproducible builds. The path is
# relative to a distributions base directory.
stack_freeze_file = freeze/pandoc-$(PANDOC_COMMIT).project.freeze

# List of Linux distributions which are supported as image bases.
# TODO: alpine
image_stacks = ubuntu

# Keep this target first so that `make` with no arguments will print this rather
# than potentially engaging in expensive builds.
.PHONY: show-args
show-args:
	@printf "# Controls whether pandoc-crossref will be built in the base image.\n"
	@printf "WITHOUT_CROSSREF=%s\n" $(WITHOUT_CROSSREF)
	@printf "\n# The tag given to the image.\n"
	@printf "PANDOC_VERSION=%s\n" $(PANDOC_VERSION)
	@printf "\n# The pandoc commit used to build the image(s);\n"
	@printf "# usually a tag or branch name.\n"
	@printf "PANDOC_COMMIT=%s\n" $(PANDOC_COMMIT)
	@printf "\n# Linux distribution used as base. List of supported base stacks:\n"
	@printf "#   %s\n" "$(supported_stacks)"
	@printf "# May be overwritten by using a stack-specific target.\n"
	@printf "STACK=%s\n" $(STACK)

# Generates the targets for a given image stack.
# $1: base stack, one of the `supported_stacks`
define stack
.PHONY: $(1) $(1)-core $(1)-crossref $(1)-latex $(1)-freeze-file
# Define targets which have the stack in their names, then set the
# `STACK` variable based on the chosen target. This is an alternative to
# setting the `STACK` variable directly and allows for convenient tab
# completion.
$(1) $(1)-core $(1)-crossref $(1)-latex $(1)-freeze-file: STACK = $(1)
$(1): $(1)-core
$(1)-core: $(1)-freeze-file core
$(1)-crossref: crossref
$(1)-latex: latex
$(1)-freeze-file: $(1)/$(stack_freeze_file)

# Do the same for test targets, again to allow for tab completion.
.PHONY: test-$(1) test-$(1)-core test-$(1)-crossref test-$(1)-latex
test-$(1) test-$(1)-core test-$(1)-crossref test-$(1)-latex: STACK = $(1)
test-$(1): test-core
test-$(1)-core: test-core
test-$(1)-crossref: test-crossref
test-$(1)-latex: test-latex
endef
# Generate convenience targets for all supported stacks.
$(foreach img,$(image_stacks),$(eval $(call stack,$(img))))

# Freeze #######################################################################
# NOTE: this will change to compute freeze file with AzP / tectonic.
#       (conditionally .PHONY freeze, point to ubuntu freeze, etc).
.PHONY: freeze-file
freeze-file: $(STACK)/$(stack_freeze_file)
%/$(stack_freeze_file): STACK = $*
%/$(stack_freeze_file): common/pandoc-freeze.sh
	docker build \
		--tag pandoc/$(STACK)-builder-base \
		--target=$(STACK)-builder-base \
		-f $(makefile_dir)/$(STACK)/Dockerfile $(makefile_dir)
	docker run --rm \
		-v "$(makefile_dir):/app" \
		pandoc/$(STACK)-builder-base \
		sh /app/$< $(PANDOC_COMMIT) "$(shell id -u):$(shell id -g)" /app/$@
# Core #########################################################################
.PHONY: core
core:
	docker build \
		--tag pandoc/$(STACK):$(PANDOC_VERSION) \
		--build-arg pandoc_commit=$(PANDOC_COMMIT) \
		--build-arg pandoc_version=$(PANDOC_VERSION) \
		--build-arg without_crossref=$(WITHOUT_CROSSREF) \
		--target $(STACK)-core \
		-f $(makefile_dir)/$(STACK)/Dockerfile $(makefile_dir)
# Crossref #####################################################################
.PHONY: crossref
crossref: core
	docker build \
		--tag pandoc/$(STACK)-crossref:$(PANDOC_VERSION) \
		--build-arg pandoc_commit=$(PANDOC_COMMIT) \
		--build-arg pandoc_version=$(PANDOC_VERSION) \
		--build-arg without_crossref=$(WITHOUT_CROSSREF) \
		--target $(STACK)-crossref \
		-f $(makefile_dir)/$(STACK)/Dockerfile $(makefile_dir)
# LaTeX ########################################################################
.PHONY: latex
latex: crossref
	docker build \
		--tag pandoc/$(STACK)-latex:$(PANDOC_VERSION) \
		--build-arg base_tag=$(PANDOC_VERSION) \
		-f $(makefile_dir)/$(STACK)/latex.Dockerfile $(makefile_dir)
# Test #########################################################################
.PHONY: test-core test-latex test-crossref
test-core: IMAGE ?= pandoc/$(STACK):$(PANDOC_VERSION)
test-core:
	IMAGE=$(IMAGE) make -C test test-core

test-crossref: IMAGE ?= pandoc/$(STACK)-crossref:$(PANDOC_VERSION)
test-crossref:
	test -n "$(WITHOUT_CROSSREF)" || IMAGE=$(IMAGE) make -C test test-crossref

test-latex: IMAGE ?= pandoc/$(STACK)-latex:$(PANDOC_VERSION)
test-latex:
	IMAGE=$(IMAGE) make -C test test-latex


################################################################################
# Alpine images and tests                                                      #
################################################################################
#
# TODO: @svenevs
# Refactor alpine stack into the glorious beauty that is the ubuntu stack.
#
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
