# Base ##################################################################
FROM debian:bookworm AS debian-minimal
ARG PANDOC=3.5
ARG LUA=5.4

LABEL maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.author "John MacFarlane"
LABEL org.pandoc.version "$pandoc_version"

# Install runtime dependencies
RUN <<EOF
set -eux
apt-get -q --no-allow-insecure-repositories update
DEBIAN_FRONTEND=noninteractive \
apt-get install --assume-yes --no-install-recommends \
    ca-certificates \
    liblua$LUA-0 \
    libatomic1 \
    libgmp10 \
    libpcre3 \
    libyaml-0-2 \
    zlib1g
rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
set -eux
cd /tmp
apt-get -q --no-allow-insecure-repositories update
# Install build dependencies
DEBIAN_FRONTEND=noninteractive \
apt-get install --assume-yes --no-install-recommends \
    build-essential \
    ca-certificates \
    cabal-install \
    curl \
    fakeroot \
    git \
    ghc \
    libgmp-dev \
    liblua$LUA-dev \
    pkg-config \
    zlib1g-dev
EOF

RUN <<EOF
set -eux; \
# Get pandoc-cli sources
cabal update
cabal get pandoc-cli-${PANDOC}
cd pandoc-cli-${PANDOC}

# Setup to include pandoc-crossref
printf 'packages: pandoc-cli.cabal\n' > cabal.project
# Add pandoc-crossref to project
printf 'extra-packages: pandoc-crossref\n' >> cabal.project
cat cabal.project
EOF

RUN <<EOF
set -eux
cd pandoc-cli-${PANDOC}
# Build and install
cabal install pandoc-cli:exes pandoc-crossref:exes \
    --jobs \
    --disable-tests \
    --disable-bench \
    --allow-newer='lib:pandoc' \
    --prefix=/usr \
    --docdir=/usr/share/doc/pandoc \
    --flags='+server +lua' \
    --sysconfdir=/etc \
    --ghc-options='-O1 -optc-Os -optl=-pthread -fPIC -j +RTS -A128m -n2m -RTS'

EOF

RUN <<EOF
set -eux
cd pandoc-cli-${PANDOC}
cabal list-bin pandoc-cli:exes | xargs install -Dm755 -t /usr/bin
# 
find /root/.cabal \
    -name 'pandoc*' -type f -perm -u+x \
    -exec strip '{}' ';' \
    -exec cp '{}' /usr/local/bin/ ';'

# cd /
# ls -l -d /root/.*
# rm -rf /root/.cabal /root/.ghc
# rm -rf /tmp/*
# rm -rf /var/lib/apt/lists/*
EOF
