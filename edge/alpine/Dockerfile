# Base ##################################################################
ARG base_image_version=3.22
FROM alpine:$base_image_version AS builder-base
WORKDIR /app

# We're already very specific about the version of the alpine image, so
# it seems reasonable not to require specific package versions.
#
# hadolint ignore=DL3018
RUN apk --no-cache add \
        alpine-sdk \
        bash \
        ca-certificates \
        cabal \
        fakeroot \
        ghc \
        git \
        gmp-dev \
        libffi \
        libffi-dev \
        lua5.4-dev \
        pkgconfig \
        yaml \
        zlib-dev

# Setup and configure cabal
ENV CABAL_CONFIG=/root/.config/cabal/config

RUN cabal user-config init \
  && cabal --version \
  && ghc --version \
  && cabal update

# Builder ###############################################################
FROM builder-base AS builder
RUN git clone --branch=main --depth=1 --quiet \
  https://github.com/jgm/pandoc /app

# Add pandoc-crossref to project
RUN printf "extra-packages: pandoc-crossref\n" > cabal.project.local;

# Build pandoc and pandoc-crossref. The `allow-newer` is required for
# when pandoc-crossref has not been updated yet, but we want to build
# anyway.
RUN cabal build \
        --jobs \
        --disable-tests \
        --disable-bench \
        --enable-split-sections \
        --enable-executable-stripping \
        --upgrade-dependencies \
        --allow-newer='lib:pandoc' \
        --ghc-options='-O1 -optc-Os -optl=-pthread -fPIC -j' \
        --ghc-options='+RTS -M4G -A128m -RTS' \
        --constraint='lua  +system-lua +pkg-config +hardcode-reg-keys -export-dynamic' \
        --constraint='lpeg  -rely-on-shared-lpeg-library' \
        --constraint='aeson-pretty  +lib-only' \
        --constraint='pandoc  +embed_data_files' \
        --constraint='pandoc-cli  +lua +nightly +server' \
        --constraint='directory +os-string' \
        --constraint='unix +os-string' \
        --constraint='any.os-string >=2.0.6' \
        . pandoc-cli pandoc-crossref

# Cabal's exec stripping doesn't seem to work reliably, let's do it here.
RUN find dist-newstyle \
         -name 'pandoc*' -type f -perm -u+x \
         -exec strip '{}' ';' \
         -exec cp '{}' /usr/local/bin/ ';'

# Minimal ###############################################################
FROM alpine:3.22 AS minimal
ARG pandoc_version=edge
LABEL maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.author="John MacFarlane"
LABEL org.pandoc.version="edge"

# Set user data directory
ENV XDG_DATA_HOME=/usr/local/share

# Set default working directory
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/pandoc"]

COPY --from=builder \
  /usr/local/bin/pandoc \
  /usr/local/bin/

# Add pandoc symlinks
#
# hadolint ignore=DL3018
RUN ln -s /usr/local/bin/pandoc /usr/local/bin/pandoc-lua && \
    ln -s /usr/local/bin/pandoc /usr/local/bin/pandoc-server && \
# Install runtime dependencies
    apk --no-cache add \
        gmp \
        libffi \
        lua5.4 && \
# Create user data directory
    mkdir -p "$XDG_DATA_HOME"/pandoc

# Core ##################################################################
FROM minimal AS core
COPY --from=builder \
  /usr/local/bin/pandoc-crossref \
  /usr/local/bin/

# Additional packages frequently used during conversions
# NOTE: `libsrvg`, pandoc uses `rsvg-convert` for working with svg images.
# FIXME: Alpine 3.17 and later ships the binary in the rsvg-convert package.
# hadolint ignore=DL3018
RUN apk --no-cache add librsvg; \
    apk --no-cache add rsvg-convert || true
