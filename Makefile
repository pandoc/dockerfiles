PANDOC_VERSION ?= edge

ifeq ($(PANDOC_VERSION),edge)
PANDOC_COMMIT          ?= main
else
PANDOC_COMMIT          ?= $(PANDOC_VERSION)
endif

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
image_stacks = alpine \
               debian \
               ubuntu \
               static

# Keep this target first so that `make` with no arguments will print this rather
# than potentially engaging in expensive builds.
.PHONY: show-args
show-args:
	@printf "# Pandoc version to build. Must be either a published version, or \n"
	@printf "# the string 'edge' to build from the development version.\n"
	@printf "PANDOC_VERSION=%s\n" $(PANDOC_VERSION)
	@printf "\n# The pandoc commit used to build the image(s);\n"
	@printf "# usually a tag or branch name.\n"
	@printf "PANDOC_COMMIT=%s\n" $(PANDOC_COMMIT)
	@printf "\n# Linux distribution used as base. List of supported base stacks:\n"
	@printf "#   %s\n" "$(image_stacks)"
	@printf "# May be overwritten by using a stack-specific target.\n"
	@printf "STACK=%s\n" $(STACK)
	@printf "\n# Controls the number of threads to be used during the build\n"
	@printf "process (use all cores when not set)\n"
	@printf "CORES=%s\n" $(CORES)

# Calculate docker build options limiting the amount of CPU time that's
# being used.
ifdef CORES
docker_options=--cpu-period="100000" --cpu-quota="$$(( $(CORES) * 100000 ))"
else
docker_options=
endif

# Generates the targets for a given image stack.
# $1: base stack, one of the `supported_stacks`
define stack
# Define targets which have the stack in their names, then set the
# `STACK` variable based on the chosen target. This is an alternative to
# setting the `STACK` variable directly and allows for convenient tab
# completion.
.PHONY: \
		$(1) \
		$(1)-minimal \
		$(1)-freeze-file
$(1) $(1)-minimal $(1)-freeze-file: STACK = $(1)
$(1): $(1)-minimal
$(1)-minimal: minimal
$(1)-freeze-file: $(1)/$(stack_freeze_file)
# Only alpine and ubuntu support core, latex, typst, and extra images
ifeq ($(1),$(filter $(1),alpine ubuntu debian))
.PHONY: \
		$(1)-core \
		$(1)-latex \
		$(1)-typst \
		$(1)-extra
$(1) $(1)-core $(1)-latex $(1)-typst $(1)-extra: STACK = $(1)
$(1)-core: core
$(1)-latex: latex
$(1)-typst: typst
$(1)-extra: extra
endif

# Do the same for test targets, again to allow for tab completion.
.PHONY: \
		test-$(1) \
		test-$(1)-minimal \
		test-$(1)-core \
		test-$(1)-latex \
		test-$(1)-extra
test-$(1) test-$(1)-minimal test-$(1)-core test-$(1)-latex test-$(1)-extra: STACK = $(1)
test-$(1): test-minimal
test-$(1)-minimal: test-minimal
ifeq ($(1),$(filter $(1),alpine ubuntu debian))
test-$(1)-core: test-core
test-$(1)-latex: test-latex
test-$(1)-extra: test-extra
endif
endef

# Generate convenience targets for all supported stacks.
$(foreach img,$(image_stacks),$(eval $(call stack,$(img))))

export TEXLIVE_MIRROR_URL

# Freeze ################################################################
.PHONY: freeze-file
freeze-file: $(STACK)/$(stack_freeze_file)
%/$(stack_freeze_file): STACK = $*
%/$(stack_freeze_file):
	docker build --force-rm \
	    --tag "pandoc/$(STACK)-builder-base:edge" \
	    --file "edge/$(STACK)/Dockerfile" \
	    --target "builder-base" \
	    $(docker_options) \
      edge
	docker run --rm \
		-v "$(makefile_dir):/app" \
		--env WITHOUT_CROSSREF=$(WITHOUT_CROSSREF) \
		pandoc/$(STACK)-builder-base:edge \
		sh /app/common/pandoc-freeze.sh \
		    -c $(PANDOC_COMMIT) \
		    -u "$(shell id -u):$(shell id -g)" \
		    -s "$(STACK)" \
		    -o /app/$@
# Minimal ###############################################################
.PHONY: minimal
minimal:
	( cd $(PANDOC_VERSION) && \
	  docker buildx bake $(STACK)-minimal $(docker_options) )
# Core ##################################################################
.PHONY: core
core:
	( cd $(PANDOC_VERSION) && \
	  docker buildx bake $(STACK)-core $(docker_options) )
# LaTeX #################################################################
.PHONY: latex
latex:
	( cd $(PANDOC_VERSION) && \
	  docker buildx bake $(STACK)-latex $(docker_options) )
# Typst #################################################################
.PHONY: typst
typst:
	( cd $(PANDOC_VERSION) && \
	  docker buildx bake $(STACK)-typst $(docker_options) )
# Extra #################################################################
.PHONY: extra
extra:
	( cd $(PANDOC_VERSION) && \
	  docker buildx bake $(STACK)-extra $(docker_options) )
# Test ##################################################################
.PHONY: test-core test-extra test-latex test-minimal test-typst
test-minimal: IMAGE ?= pandoc/minimal:$(PANDOC_VERSION)-$(STACK)
test-minimal:
	IMAGE=$(IMAGE) make -C test test-minimal

test-core: IMAGE ?= pandoc/core:$(PANDOC_VERSION)-$(STACK)
test-core:
	test -n "$(WITHOUT_CROSSREF)" || IMAGE=$(IMAGE) make -C test test-core

test-latex: IMAGE ?= pandoc/latex:$(PANDOC_VERSION)-$(STACK)
test-latex:
	IMAGE=$(IMAGE) make -C test test-latex

test-extra: IMAGE ?= pandoc/extra:$(PANDOC_VERSION)-$(STACK)
test-extra:
	IMAGE=$(IMAGE) make -C test test-extra

test-typst: IMAGE ?= pandoc/typst:$(PANDOC_VERSION)-$(STACK)
test-typst:
	IMAGE=$(IMAGE) make -C test test-typst

########################################################################
# Developer targets                                                    #
########################################################################
.PHONY: lint
lint:
	shellcheck $(shell find . -name "*.sh")

.PHONY: docs \
		docs-minimal \
		docs-core \
		docs-latex \
		docs-extra \
		docs-typst \

docs:
	@pandoc "docs/$(REPO).md" \
		--lua-filter="docs/filters/transclude.lua" \
		--lua-filter="docs/filters/supported-tags.lua" \
		--lua-filter="docs/filters/texlive-versions.lua" \
		--lua-filter="docs/filters/fix-run.lua" \
		--to=commonmark

docs-minimal: REPO = minimal
docs-minimal: docs

docs-core: REPO = core
docs-core: docs

docs-latex: REPO = latex
docs-latex: docs

docs-extra: REPO = extra
docs-extra: docs

docs-typst: REPO = typst
docs-typst: docs

.PHONY: clean
clean:
	IMAGE=none make -C test clean
