# Builder ###############################################################
ARG base_image_version=3.22
FROM alpine:$base_image_version
WORKDIR /app

# Default busybox shell; we specify it explicitly mainly because
# hadolint/ShellCheck needs to know that `pipefail` is defined.
SHELL ["/bin/ash", "-c"]

# Set user data directory
ENV XDG_DATA_HOME=/usr/local/share

# This is an ever-changing image, it's not a problem if packages don't
# have a specific version.
#
# hadolint ignore=DL3018
RUN set -euo pipefail; \
    apk add --no-cache --no-progress --quiet --virtual .build-deps \
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
        zlib-dev \
    ; \
    git clone https://github.com/jgm/pandoc.git /app; \
    printf 'extra-packages: pandoc-crossref\n' > cabal.project.local \
    ; \
# Build pandoc and pandoc-crossref.
    cabal update; \
    cabal build \
        --jobs \
        --disable-tests \
        --disable-bench \
        --enable-split-sections \
        --enable-executable-stripping \
        --upgrade-dependencies \
        --ghc-options='-O1 -optc-Os -optl=-pthread -fPIC -j' \
        --ghc-options='+RTS -M4G -A128m -RTS' \
        --constraint='aeson-pretty +lib-only' \
        --constraint='lua  +pkg-config' \
        --constraint='lpeg  -rely-on-shared-lpeg-library' \
        --constraint='pandoc  +embed_data_files' \
        --constraint='pandoc-cli  +lua +nightly +server' \
        . pandoc-cli pandoc-crossref \
    ; \
# Cabal's exec stripping doesn't seem to work reliably, let's do it here.
    find dist-newstyle \
        -name 'pandoc*' -type f -perm -u+x \
        -exec strip '{}' ';' \
        -exec cp '{}' /usr/local/bin/ ';' \
    ; \
# Build cleanup
    rm -rf \
        /app \
        /root/.cabal \
        /root/.cache \
        /root/.config \
        /root/.local \
    ;\
    apk del .build-deps; \
# Add pandoc symlinks
    ln -s /usr/local/bin/pandoc /usr/local/bin/pandoc-lua; \
    ln -s /usr/local/bin/pandoc /usr/local/bin/pandoc-server; \
# Create user data directory
    mkdir -p "$XDG_DATA_HOME"/pandoc; \
# Install pandoc runtime dependencies
    apk --no-cache add \
        gmp \
        libffi \
        lua5.4 \
        rsvg-convert \
    ;


LABEL maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.author="John MacFarlane"
LABEL org.pandoc.version="edge"

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/pandoc"]
