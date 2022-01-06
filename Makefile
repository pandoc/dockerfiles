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

ifndef extra_packages
ifndef WITHOUT_CROSSREF
extra_packages += pandoc-crossref
endif
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
               ubuntu \
               static

# Keep this target first so that `make` with no arguments will print this rather
# than potentially engaging in expensive builds.
.PHONY: show-args
show-args:
	@printf "# Controls whether pandoc-crossref will be built in the base image.\n"
	@printf "WITHOUT_CROSSREF=%s\n" $(WITHOUT_CROSSREF)
	@printf "# Pandoc version to build. Must be either a published version, or \n"
	@printf "# the string 'edge' to build from the development version.\n"
	@printf "PANDOC_VERSION=%s\n" $(PANDOC_VERSION)
	@printf "\n# The pandoc commit used to build the image(s);\n"
	@printf "# usually a tag or branch name.\n"
	@printf "PANDOC_COMMIT=%s\n" $(PANDOC_COMMIT)
	@printf "\n# Linux distribution used as base. List of supported base stacks:\n"
	@printf "#   %s\n" "$(supported_stacks)"
	@printf "# May be overwritten by using a stack-specific target.\n"
	@printf "STACK=%s\n" $(STACK)
	@printf "\n# Additional packages build alongside pandoc. Controlled via\n"
	@printf "# WITHOUT_CROSSREF; not intended to be set directly.\n"
	@printf "extra_packages=%s\n" "$(extra_packages)"
	@printf "\n# Controls the number of threads to be used during the build\n"
	@printf "process (use all cores when not set)\n"
	@printf "CORES=%s\n" $(CORES)

# Calculate docker build options limiting the amount of CPU time that's
# being used.
ifdef CORES
docker_cpu_options=--cpu-period="100000" --cpu-quota="$$(( $(CORES) * 100000 ))"
else
docker_cpu_options=
endif

# Generates the targets for a given image stack.
# $1: base stack, one of the `supported_stacks`
define stack
# Define targets which have the stack in their names, then set the
# `STACK` variable based on the chosen target. This is an alternative to
# setting the `STACK` variable directly and allows for convenient tab
# completion.
.PHONY: $(1) $(1)-core $(1)-freeze-file
$(1) $(1)-core $(1)-crossref $(1)-latex $(1)-freeze-file: STACK = $(1)
$(1): $(1)-core
$(1)-core: $(1)-freeze-file core
$(1)-freeze-file: $(1)/$(stack_freeze_file)
# Only alpine and ubuntu support crossref and latex images
ifeq ($(1),$(filter $(1),alpine ubuntu))
.PHONY: $(1)-crossref $(1)-latex
$(1)-crossref: crossref
$(1)-latex: latex
endif

# Do the same for test targets, again to allow for tab completion.
.PHONY: test-$(1) test-$(1)-core test-$(1)-crossref test-$(1)-latex
test-$(1) test-$(1)-core test-$(1)-crossref test-$(1)-latex: STACK = $(1)
test-$(1): test-core
test-$(1)-core: test-core
ifeq ($(1),$(filter $(1),alpine ubuntu))
test-$(1)-crossref: test-crossref
test-$(1)-latex: test-latex
endif
endef
# Generate convenience targets for all supported stacks.
$(foreach img,$(image_stacks),$(eval $(call stack,$(img))))

# Freeze #######################################################################
.PHONY: freeze-file
freeze-file: $(STACK)/$(stack_freeze_file)
%/$(stack_freeze_file): STACK = $*
%/$(stack_freeze_file): common/pandoc-freeze.sh
	docker build $(docker_cpu_options) \
		--tag pandoc/$(STACK)-builder-base \
		--target=$(STACK)-builder-base \
		-f $(makefile_dir)/$(STACK)/Dockerfile $(makefile_dir)
	docker run --rm \
		-v "$(makefile_dir):/app" \
	  --env WITHOUT_CROSSREF=$(WITHOUT_CROSSREF) \
		pandoc/$(STACK)-builder-base \
		sh /app/$< -c $(PANDOC_COMMIT) \
               -u "$(shell id -u):$(shell id -g)" \
               -s "$(STACK)" \
               -o /app/$@
# Core #########################################################################
.PHONY: core
core:
	docker build $(docker_cpu_options) \
		--tag pandoc/core:$(PANDOC_VERSION)-$(STACK) \
		--build-arg pandoc_commit=$(PANDOC_COMMIT) \
		--build-arg pandoc_version=$(PANDOC_VERSION) \
		--build-arg without_crossref=$(WITHOUT_CROSSREF) \
		--build-arg extra_packages="$(extra_packages)" \
		--target $(STACK)-core \
		-f $(makefile_dir)/$(STACK)/Dockerfile $(makefile_dir)
# Crossref #####################################################################
.PHONY: crossref
crossref: core
	docker build $(docker_cpu_options) \
		--tag pandoc/crossref:$(PANDOC_VERSION)-$(STACK) \
		--build-arg pandoc_commit=$(PANDOC_COMMIT) \
		--build-arg pandoc_version=$(PANDOC_VERSION) \
		--build-arg without_crossref=$(WITHOUT_CROSSREF) \
		--build-arg extra_packages="$(extra_packages)" \
		--target $(STACK)-crossref \
		-f $(makefile_dir)/$(STACK)/Dockerfile $(makefile_dir)
# LaTeX ########################################################################
.PHONY: latex
latex: crossref
	docker build $(docker_cpu_options) \
		--tag pandoc/latex:$(PANDOC_VERSION)-$(STACK) \
		--build-arg base_tag=$(PANDOC_VERSION) \
		-f $(makefile_dir)/$(STACK)/latex.Dockerfile $(makefile_dir)
# Test #########################################################################
.PHONY: test-core test-latex test-crossref
test-core: IMAGE ?= pandoc/core:$(PANDOC_VERSION)-$(STACK)
test-core:
	IMAGE=$(IMAGE) make -C test test-core

test-crossref: IMAGE ?= pandoc/crossref:$(PANDOC_VERSION)-$(STACK)
test-crossref:
	test -n "$(WITHOUT_CROSSREF)" || IMAGE=$(IMAGE) make -C test test-crossref

test-latex: IMAGE ?= pandoc/latex:$(PANDOC_VERSION)-$(STACK)
test-latex:
	IMAGE=$(IMAGE) make -C test test-latex

################################################################################
# Developer targets                                                            #
################################################################################
.PHONY: lint
lint:
	shellcheck $(shell find . -name "*.sh")

.PHONY: push-as-latest
push-as-latest: image_names = core latex
push-as-latest:
	for image in $(image_names); do \
	    docker pull pandoc/$${image}:$(PANDOC_VERSION)-alpine; \
	    docker tag pandoc/$${image}:$(PANDOC_VERSION)-alpine \
             pandoc/$${image}:latest; \
	    docker push pandoc/$${image}:latest; \
	done

.PHONY: clean
clean:
	IMAGE=none make -C test clean
