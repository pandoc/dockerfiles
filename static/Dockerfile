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
FROM static-builder-base as static-builder
ARG pandoc_commit=master
RUN git clone --branch=$pandoc_commit --depth=1 --quiet \
  https://github.com/jgm/pandoc /usr/src/pandoc

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
FROM scratch as static-minimal
ARG pandoc_version=edge
LABEL maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.author "John MacFarlane"
LABEL org.pandoc.version "$pandoc_version"

WORKDIR /data
ENTRYPOINT ["/pandoc"]

COPY --from=static-builder \
  /usr/local/bin/pandoc \
  /pandoc
