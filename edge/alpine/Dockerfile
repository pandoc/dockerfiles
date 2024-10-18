# Builder ###############################################################
ARG base_image_version=3.20
FROM alpine:$base_image_version AS alpine-builder
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

RUN <<EOF
set -ex;
curl -sSL \
    -o /tmp/pandoc.zip \
    https://github.com/jgm/pandoc/archive/refs/heads/main.zip
cd /tmp
unzip -q pandoc.zip
cd pandoc-main
printf 'extra-packages: pandoc-crossref\n' > cabal.project.local;

# Build pandoc and pandoc-crossref. The `allow-newer` is required for
# when pandoc-crossref has not been updated yet, but we want to build
# anyway.
cabal update
cabal build \
    --jobs \
    --disable-tests \
    --disable-bench \
    --enable-split-sections \
    --enable-executable-stripping \
    --upgrade-dependencies \
    --ghc-options='-O -optc-Os -optl=-pthread -fPIC -j4 +RTS -M4G -A256m -RTS' \
    --constraint='aeson-pretty +lib-only' \
    --constraint='lua +pkg-config' \
    --constraint='lpeg  -rely-on-shared-lpeg-library' \
    --constraint='pandoc +embed_data_files' \
    --constraint='pandoc-cli +lua +nightly +server' \
    . pandoc-cli pandoc-crossref

# Cabal's exec stripping doesn't seem to work reliably, let's do it here.
find dist-newstyle \
    -name 'pandoc*' -type f -perm -u+x \
    -exec strip '{}' ';' \
    -exec cp '{}' /usr/local/bin/ ';'

rm -rf /root/.cabal
EOF

# Minimal ###############################################################
FROM alpine:$base_image_version AS minimal
ARG pandoc_version=edge
LABEL maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.author="John MacFarlane"
LABEL org.pandoc.version="$pandoc_version"

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/pandoc"]

COPY --from=alpine-builder \
  /usr/local/bin/pandoc \
  /usr/local/bin/

# Add pandoc symlinks
RUN ln -s /usr/local/bin/pandoc /usr/local/bin/pandoc-lua && \
    ln -s /usr/local/bin/pandoc /usr/local/bin/pandoc-server && \
# Install runtime dependencies
    apk --no-cache add \
        gmp \
        libffi \
        lua5.4

# Core ##################################################################
FROM minimal AS core
COPY --from=alpine-builder \
  /usr/local/bin/pandoc-crossref \
  /usr/local/bin/

# Additional packages frequently used during conversions
# NOTE: `libsrvg`, pandoc uses `rsvg-convert` for working with svg images.
RUN apk --no-cache add rsvg-convert
