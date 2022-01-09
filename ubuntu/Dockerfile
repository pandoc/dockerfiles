# Base ##################################################################
ARG base_image_version=focal
FROM ubuntu:$base_image_version AS ubuntu-builder-base
WORKDIR /app

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -q --no-allow-insecure-repositories update \
  && apt-get install --assume-yes --no-install-recommends \
       software-properties-common \
  && add-apt-repository ppa:hvr/ghc \
  && apt-get install --assume-yes --no-install-recommends \
       ghc-8.8.3=8.8.3-* \
       cabal-install-3.2=3.2* \
       build-essential=* \
       ca-certificates=* \
       curl=* \
       fakeroot=* \
       git \
       libgmp-dev=2:6.* \
       liblua5.3-dev=5.3.* \
       pkg-config=* \
       zlib1g-dev=1:1.2.11.* \
  && rm -rf /var/lib/apt/lists/* \
  && ln -s /opt/ghc/bin/ghc /usr/bin/ghc \
  && ln -s /opt/cabal/bin/cabal /usr/bin/cabal

COPY cabal.root.config /root/.cabal/config
RUN cabal --version \
  && ghc --version \
  && cabal v2-update

# Builder ###############################################################
FROM ubuntu-builder-base as ubuntu-builder
ARG pandoc_commit=master
RUN git clone --branch=$pandoc_commit --depth=1 --quiet \
  https://github.com/jgm/pandoc /usr/src/pandoc

COPY ./ubuntu/freeze/pandoc-$pandoc_commit.project.freeze \
     /usr/src/pandoc/cabal.project.freeze

# Install Haskell dependencies
WORKDIR /usr/src/pandoc
# Add pandoc-crossref to project
ARG without_crossref=
ARG extra_packages="pandoc-crossref"
RUN test -n "$without_crossref" || \
    printf "extra-packages: pandoc-crossref\n" > cabal.project.local;

RUN cabal v2-update \
  && cabal v2-build \
      --disable-tests \
      --jobs \
      . $extra_packages

# Cabal's exec stripping doesn't seem to work reliably, let's do it here.
RUN find dist-newstyle \
         -name 'pandoc*' -type f -perm -u+x \
         -exec strip '{}' ';' \
         -exec cp '{}' /usr/local/bin/ ';'

# Minimal ###############################################################
FROM ubuntu:focal AS ubuntu-minimal
ARG pandoc_version=edge
LABEL maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.author "John MacFarlane"
LABEL org.pandoc.version "$pandoc_version"

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/pandoc"]

COPY --from=ubuntu-builder \
  /usr/local/bin/pandoc \
  /usr/local/bin/

# Reinstall any system packages required for runtime.
RUN apt-get -q --no-allow-insecure-repositories update \
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends \
       ca-certificates=* \
       liblua5.3-0=5.3.3* \
       lua-lpeg=1.0.* \
       libatomic1=10* \
       libgmp10=2:6.* \
       libpcre3=2:8.39-* \
       libyaml-0-2=0.2.* \
       zlib1g=1:1.2.11.* \
  && rm -rf /var/lib/apt/lists/*

# Core ##################################################################
FROM ubuntu-minimal AS ubuntu-core
COPY --from=ubuntu-builder \
  /usr/local/bin/pandoc-crossref \
  /usr/local/bin/

# Additional packages frequently used during conversions
# NOTE: `libsrvg`, pandoc uses `rsvg-convert` for working with svg images.
RUN apt-get -q --no-allow-insecure-repositories update \
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends \
       librsvg2-bin=2.* \
  && rm -rf /var/lib/apt/lists/*

# LaTeX ##############################################################
FROM ubuntu-core as ubuntu-latex

# NOTE: to maintainers, please keep this listing alphabetical.
RUN apt-get -q --no-allow-insecure-repositories update \
  && DEBIAN_FRONTEND=noninteractive \
     apt-get install --assume-yes --no-install-recommends \
        fontconfig \
        gnupg \
        gzip \
        libfontconfig1 \
        libfreetype6 \
        perl \
        tar \
        wget \
        xzdec \
  && rm -rf /var/lib/apt/lists/*

# DANGER: this will vary for different distributions,
# particularly the `linux` suffix. Ubuntu linux is a glibc based
# distribution, adjust depending on the distro.
# `-linux` ----------------------------> vvvvv
ENV PATH="/opt/texlive/texdir/bin/x86_64-linux:${PATH}"
WORKDIR /root

COPY common/latex/texlive.profile /root/texlive.profile
COPY common/latex/install-texlive.sh /root/install-texlive.sh
COPY common/latex/install-tex-packages.sh /root/install-tex-packages.sh

# TeXLive version to install (leave empty to use the latest version).
ARG texlive_version=

# Request musl precompiled binary access
RUN /root/install-texlive.sh $texlive_version \
  && /root/install-tex-packages.sh \
  && rm -f /root/texlive.profile \
           /root/install-texlive.sh \
           /root/install-tex-packages.sh

WORKDIR /data
