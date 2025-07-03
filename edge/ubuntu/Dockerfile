# Builder ###############################################################
ARG base_image_version=noble
FROM ubuntu:$base_image_version
WORKDIR /app

# Set user data directory
ENV XDG_DATA_HOME=/usr/local/share

# This is an ever-changing image, it's not a problem if packages don't
# have a specific version.
#
# hadolint ignore=DL3008,SC2086
RUN set -eux; \
    apt-get -q --no-allow-insecure-repositories update; \
    build_dependencies="\
        build-essential \
        cabal-install \
        curl \
        fakeroot \
        git \
        ghc \
        libgmp-dev \
        liblua5.4-dev \
        pkg-config \
        zlib1g-dev \
    ";\
    runtime_dependencies="\
        ca-certificates \
        liblua5.4-0 \
        libatomic1 \
        libgmp10 \
        libpcre3 \
        librsvg2-bin \
        libyaml-0-2 \
        zlib1g \
    ";\
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes --no-install-recommends \
        $build_dependencies \
        $runtime_dependencies \
    ; \
    git clone --branch=main --depth=1 --quiet \
        https://github.com/jgm/pandoc /app; \
    printf 'extra-packages: pandoc-crossref\n' > cabal.project.local; \
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
    apt-get remove --assume-yes --autoremove --purge $build_dependencies; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf \
        /app \
        /root/.cabal \
        /root/.cache \
        /root/.config \
        /root/.local \
    ;\
# Add pandoc symlinks
    ln -s /usr/local/bin/pandoc /usr/local/bin/pandoc-lua; \
    ln -s /usr/local/bin/pandoc /usr/local/bin/pandoc-server; \
# Create user data directory
    mkdir -p "$XDG_DATA_HOME"/pandoc \
    ;

LABEL maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@tarleb.com>'
LABEL org.pandoc.author="John MacFarlane"
LABEL org.pandoc.version="edge"

# Set default working directory
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/pandoc"]
