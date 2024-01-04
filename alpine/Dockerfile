# Base ##################################################################
ARG base_image_version=3.19.0
FROM alpine:$base_image_version AS alpine-builder-base
WORKDIR /app

ARG lua_version=5.4
RUN apk --no-cache add \
        alpine-sdk \
        bash \
        binutils-gold \
        ca-certificates \
        curl \
        fakeroot \
        gcc \
        git \
        gmp-dev \
        g++ \
        libc-dev \
        libffi \
        libffi-dev \
        lua$lua_version-dev \
        make \
        musl-dev \
        ncurses-dev \
        perl \
        pkgconfig \
        tar \
        xz \
        yaml \
        zlib-dev

# Install GHCup, GHC, Cabal
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
# Add ghcup to PATH
ENV PATH=${PATH}:/root/.local/bin
ENV PATH=${PATH}:/root/.ghcup/bin
# Update Path to include Cabal and GHC exports
RUN bash -c "echo PATH="$HOME/.local/bin:$PATH" >> $HOME/.bashrc"
RUN bash -c "echo export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" >> $HOME/.bashrc"
RUN bash -c "source $HOME/.bashrc"

# Use the same minor GHC version as Pandoc
RUN ghcup install ghc --set 9.6
RUN ghcup install cabal --set 3.10


COPY cabal.root.config /root/.cabal/config
RUN cabal --version \
  && ghc --version \
  && cabal v2-update

# Builder ###############################################################
FROM alpine-builder-base as alpine-builder
ARG pandoc_commit=main
RUN git clone --branch=$pandoc_commit --depth=1 --quiet \
  https://github.com/jgm/pandoc /usr/src/pandoc

# Remove the settings that ship with pandoc.
RUN rm -f cabal.project

COPY ./alpine/freeze/pandoc-$pandoc_commit.project.freeze \
     /usr/src/pandoc/cabal.project.freeze

# Install Haskell dependencies
WORKDIR /usr/src/pandoc
# Add pandoc-crossref to project
ARG without_crossref=
RUN test -n "$without_crossref" || \
    printf "extra-packages: pandoc-crossref\n" > cabal.project.local;

# Additional projects to compile alongside pandoc
ARG extra_packages="pandoc-cli pandoc-crossref"

# Build pandoc and pandoc-crossref. The `allow-newer` is required for
# when pandoc-crossref has not been updated yet, but we want to build
# anyway.
RUN cabal v2-update \
  && cabal v2-build \
      --allow-newer 'lib:pandoc' \
      --disable-tests \
      --disable-bench \
      --jobs \
      . $extra_packages

# Cabal's exec stripping doesn't seem to work reliably, let's do it here.
RUN find dist-newstyle \
         -name 'pandoc*' -type f -perm -u+x \
         -exec strip '{}' ';' \
         -exec cp '{}' /usr/local/bin/ ';'

# Minimal ###############################################################
FROM alpine:$base_image_version AS alpine-minimal
ARG pandoc_version=edge
ARG lua_version=5.4
LABEL maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.author "John MacFarlane"
LABEL org.pandoc.version "$pandoc_version"

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/pandoc"]

COPY --from=alpine-builder \
  /usr/local/bin/pandoc \
  /usr/local/bin/

# Reinstall any system packages required for runtime.
RUN apk --no-cache add \
        gmp \
        libffi \
        lua$lua_version \
        lua$lua_version-lpeg

# Core ##################################################################
FROM alpine-minimal AS alpine-core
COPY --from=alpine-builder \
  /usr/local/bin/pandoc-crossref \
  /usr/local/bin/

# Additional packages frequently used during conversions
# NOTE: `libsrvg`, pandoc uses `rsvg-convert` for working with svg images.
RUN apk --no-cache add \
        librsvg

# LaTeX #################################################################
FROM alpine-core as alpine-latex

# NOTE: to maintainers, please keep this listing alphabetical.
RUN apk --no-cache add \
        bind-tools \
        curl \
        fontconfig \
        freetype \
        gnupg \
        gzip \
        perl \
        tar \
        xz

# TeXLive binaries location
ARG texlive_bin="/opt/texlive/texdir/bin"

# The architecture suffix may vary based on different distributions,
# particularly for musl libc based distrubions, like Alpine linux,
# where the suffix is linuxmusl
RUN TEXLIVE_ARCH="$(uname -m)-linuxmusl" && \
    mkdir -p ${texlive_bin} && \
    ln -sf "${texlive_bin}/${TEXLIVE_ARCH}" "${texlive_bin}/default"

# Modify PATH environment variable, prepending TexLive bin directory
ENV PATH="${texlive_bin}/default:${PATH}"

WORKDIR /root

# Installer scripts and config
COPY common/latex/texlive.profile /root/texlive.profile
COPY common/latex/install-texlive.sh /root/install-texlive.sh
COPY common/latex/packages.txt /root/packages.txt

# TeXLive version to install (leave empty to use the latest version).
ARG texlive_version=

# Request musl precompiled binary access
RUN echo "binary_x86_64-linuxmusl 1" >> /root/texlive.profile \
  && /root/install-texlive.sh $texlive_version \
  && sed -e 's/ *#.*$//' -e '/^ *$/d' /root/packages.txt | \
     xargs tlmgr install \
  && rm -f /root/texlive.profile \
           /root/install-texlive.sh \
           /root/packages.txt \
  && TERM=dumb luaotfload-tool --update \
  && chmod -R o+w /opt/texlive/texdir/texmf-var

WORKDIR /data

# extra ##############################################################
FROM alpine-latex as alpine-extra

COPY common/latex/texlive.profile /root/texlive.profile
COPY common/extra/packages.txt /root/extra_packages.txt
COPY common/extra/requirements.txt /root/extra_requirements.txt

RUN apk --no-cache add py-pip

RUN sed -e 's/ *#.*$//' -e '/^ *$/d' /root/extra_packages.txt | \
    xargs tlmgr install \
  && rm -f /root/texlive.profile \
           /root/extra_packages.txt

RUN python3 -m venv .venv \
  && . .venv/bin/activate \
  && pip --no-cache-dir install -r /root/extra_requirements.txt \
  && rm -f /root/extra_requirements.txt

ARG TEMPLATES_DIR=/.pandoc/templates

RUN mkdir -p ${TEMPLATES_DIR} && \
    ln -s /.pandoc /root/.pandoc

# eisvogel
ARG EISVOGEL_REPO=https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template
ARG EISVOGEL_VERSION=v2.4.0
RUN curl -o ${TEMPLATES_DIR}/eisvogel.latex ${EISVOGEL_REPO}/${EISVOGEL_VERSION}/eisvogel.tex
