# Builder
ARG base_image_version=3.14
FROM alpine:$base_image_version AS static-builder-base
WORKDIR /app

RUN apk --no-cache add \
        alpine-sdk \
        bash \
        ca-certificates \
        cabal \
        fakeroot \
        ghc \
        git \
        gmp-dev \
        libffi-dev \
        zlib-dev \
        zlib-static

COPY cabal.root.config /root/.cabal/config

# Builder ###############################################################
FROM static-builder-base AS static-builder
ARG pandoc_commit=main
RUN git clone --branch=$pandoc_commit --depth=1 --quiet \
  https://github.com/jgm/pandoc /usr/src/pandoc

# Remove the settings that ship with pandoc, unless we're building the main
# branch.
RUN [ "${pandoc_commit}" = "main" ] || rm -f cabal.project

COPY ./static/freeze/pandoc-$pandoc_commit.project.freeze \
     /usr/src/pandoc/cabal.project.freeze

# Install Haskell dependencies
ARG extra_packages="pandoc-cli"
WORKDIR /usr/src/pandoc
RUN cabal v2-update \
  && cabal v2-configure \
      --disable-tests \
      --enable-executable-static \
      --ghc-options '-split-sections' \
      . $extra_packages \
  && cabal v2-build \
      --jobs \
      . $extra_packages

# Cabal's exec stripping doesn't seem to work reliably, let's do it here.
RUN find dist-newstyle \
         -name 'pandoc*' -type f -perm -u+x \
         -exec strip '{}' ';' \
         -exec cp '{}' /usr/local/bin/ ';'

# Minimal ###############################################################
FROM scratch AS static-minimal
ARG pandoc_version=edge
LABEL maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.author "John MacFarlane"
LABEL org.pandoc.version "$pandoc_version"

# Copy the pandoc binary
COPY --from=static-builder \
    /usr/local/bin/pandoc \
    /pandoc

# Create a /tmp folder with the correct permissions
ADD static/tmp.tar /

# Create and set user data directory
ENV XDG_DATA_HOME=/usr/local/share
WORKDIR $XDG_DATA_HOME/pandoc

# Set default working directory
WORKDIR /data
ENTRYPOINT ["/pandoc"]
