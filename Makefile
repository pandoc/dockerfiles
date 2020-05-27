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
WITHOUT_CROSSREF ?= ""

# Used to specify the build context path for Docker.  Note that we are
# specifying the repository root so that we can
#
#     COPY latex-common/texlive.profile /root
#
# for example.  If writing a COPY statement in *ANY* Dockerfile, just know that
# it is from the repository root.
makefile_dir := $(dir $(realpath Makefile))

# The freeze file fixes the versions of Haskell packages used to compile a
# specific version. This enables reproducible builds.
ubuntu_freeze_file = ubuntu/freeze/pandoc-$(PANDOC_COMMIT).project.freeze

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
# Ubuntu images and tests                                                      #
################################################################################
.PHONY: ubuntu ubuntu-crossref ubuntu-latex ubuntu-freeze-file
ubuntu: $(ubuntu_freeze_file)
	docker build \
	    --tag pandoc/ubuntu:$(PANDOC_VERSION) \
	    --build-arg pandoc_commit=$(PANDOC_COMMIT) \
	    --build-arg pandoc_version=$(PANDOC_VERSION) \
	    --build-arg without_crossref=$(WITHOUT_CROSSREF) \
	    --target focal-pandoc \
	    -f $(makefile_dir)/ubuntu/Dockerfile $(makefile_dir)

ubuntu-crossref: ubuntu
	docker build \
	    --tag pandoc/ubuntu-crossref:$(PANDOC_VERSION) \
	    --build-arg pandoc_commit=$(PANDOC_COMMIT) \
	    --build-arg pandoc_version=$(PANDOC_VERSION) \
	    --build-arg without_crossref=$(WITHOUT_CROSSREF) \
	    --target focal-pandoc-crossref \
	    -f $(makefile_dir)/ubuntu/Dockerfile $(makefile_dir)

ubuntu-latex: ubuntu-crossref
	docker build \
	    --tag pandoc/ubuntu-latex:$(PANDOC_VERSION) \
	    --build-arg base_tag=$(PANDOC_VERSION) \
	    -f $(makefile_dir)/ubuntu/latex.Dockerfile $(makefile_dir)

ubuntu-freeze-file: $(ubuntu_freeze_file)

$(ubuntu_freeze_file): common/pandoc-freeze.sh
	docker build \
	    --tag pandoc/ubuntu-builder \
	    --target=ubuntu-builder-common \
	    -f $(makefile_dir)/ubuntu/Dockerfile $(makefile_dir)
	docker run --rm \
	    -v "$(makefile_dir):/app" \
	    pandoc/ubuntu-builder \
	    sh /app/$< $(PANDOC_COMMIT) "$(shell id -u):$(shell id -g)" /app/$@

.PHONY: test-ubuntu test-ubuntu-latex
test-ubuntu: IMAGE ?= pandoc/ubuntu-core:$(PANDOC_VERSION)
test-ubuntu:
	IMAGE=$(IMAGE) make -C test test-core

test-ubuntu-latex: IMAGE ?= pandoc/ubuntu-latex:$(PANDOC_VERSION)
test-ubuntu-latex:
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
