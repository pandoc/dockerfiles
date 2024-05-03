# Base ##################################################################
ARG base_image_version=noble
FROM ubuntu:$base_image_version AS ubuntu-builder-base
WORKDIR /app

## Not sure why we have to repeat this, but apparently the arg is no
## longer set after FROM.
ARG base_image_version=noble
ARG lua_version=5.4
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -q --no-allow-insecure-repositories update \
  && apt-get install --assume-yes --no-install-recommends \
       build-essential=* \
       ca-certificates=* \
       cabal-install=* \
       curl=* \
       fakeroot=* \
       git \
       ghc=* \
       libgmp-dev=2:6.* \
       liblua$lua_version-dev=* \
       pkg-config=* \
       zlib1g-dev=* \
  && rm -rf /var/lib/apt/lists/*

COPY cabal.root.config /root/.cabal/config
RUN cabal --version \
  && ghc --version \
  && cabal v2-update

# Builder ###############################################################
FROM ubuntu-builder-base as ubuntu-builder
ARG pandoc_commit=main
RUN git clone --branch=$pandoc_commit --depth=1 --quiet \
  https://github.com/jgm/pandoc /usr/src/pandoc

# Remove the settings that ship with pandoc.
RUN rm -f cabal.project

COPY ./ubuntu/freeze/pandoc-$pandoc_commit.project.freeze \
     /usr/src/pandoc/cabal.project.freeze

# Install Haskell dependencies
WORKDIR /usr/src/pandoc
# Add pandoc-crossref to project
ARG without_crossref=
ARG extra_packages="pandoc-cli pandoc-crossref"
RUN test -n "$without_crossref" || \
    printf "extra-packages: pandoc-crossref\n" > cabal.project.local;

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
FROM ubuntu:$base_image_version AS ubuntu-minimal
ARG pandoc_version=edge
ARG lua_version=5.4
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
       ca-certificates=\* \
       liblua$lua_version-0=\* \
       lua-lpeg=\* \
       libatomic1=\* \
       libgmp10=\* \
       libpcre3=\* \
       libyaml-0-2=\* \
       zlib1g=\* \
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

# TeXLive binaries location
ARG texlive_bin="/opt/texlive/texdir/bin"

RUN TEXLIVE_ARCH="$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')" && \
    mkdir -p ${texlive_bin} && \
    ln -sf "${texlive_bin}/${TEXLIVE_ARCH}" "${texlive_bin}/default"

# Modify PATH environment variable, prepending TexLive bin directory
ENV PATH="${texlive_bin}/default:${PATH}"

WORKDIR /root

COPY common/latex/texlive.profile /root/texlive.profile
COPY common/latex/install-texlive.sh /root/install-texlive.sh
COPY common/latex/packages.txt /root/packages.txt

# TeXLive version to install (leave empty to use the latest version).
ARG texlive_version=

RUN /root/install-texlive.sh $texlive_version \
  && sed -e 's/ *#.*$//' -e '/^ *$/d' /root/packages.txt | \
     xargs tlmgr install \
  && rm -f /root/texlive.profile \
           /root/install-texlive.sh \
           /root/packages.txt \
  && TERM=dumb luaotfload-tool --update \
  && chmod -R o+w /opt/texlive/texdir/texmf-var

WORKDIR /data

# extra ##############################################################
FROM ubuntu-latex as ubuntu-extra

COPY common/latex/texlive.profile /root/texlive.profile
COPY common/extra/packages.txt /root/extra_packages.txt
COPY common/extra/requirements.txt /root/extra_requirements.txt

RUN apt-get -q --no-allow-insecure-repositories update \
  && apt-get install --assume-yes --no-install-recommends \
        python3-pip

RUN sed -e 's/ *#.*$//' -e '/^ *$/d' /root/extra_packages.txt | \
    xargs tlmgr install \
  && rm -f /root/texlive.profile \
           /root/extra_packages.txt

RUN pip3 --no-cache-dir install -r /root/extra_requirements.txt \
  && rm -f /root/extra_requirements.txt

# Templates
#
# If docker is run with the `--user` option, the $HOME var
# is empty when the user does not exist inside the container.
# This causes several problems for pandoc. We solve the issue
# by putting the pandoc templates in a shared space (TEMPLATES_DIR)
# and creating symbolic links inside the `/root` home so that
# the templates and packages can be accessed by root and a
# non-existent `--user`
#
ARG TEMPLATES_DIR=/.pandoc/templates

RUN mkdir -p ${TEMPLATES_DIR} && \
    ln -s /.pandoc /root/.pandoc

# eisvogel
ARG EISVOGEL_REPO=https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template
ARG EISVOGEL_VERSION=v2.4.0
RUN wget ${EISVOGEL_REPO}/${EISVOGEL_VERSION}/eisvogel.tex -O ${TEMPLATES_DIR}/eisvogel.latex
