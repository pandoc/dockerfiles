# Base #########################################################################
FROM ubuntu:focal AS ubuntu-builder-base
WORKDIR /app

# begin(ubuntu-local)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -q --no-allow-insecure-repositories update \
  && apt-get install --assume-yes --no-install-recommends \
       software-properties-common \
  && add-apt-repository ppa:hvr/ghc \
  && apt-get install --assume-yes --no-install-recommends \
       ghc-8.8.3=8.8.3-* \
       cabal-install-3.2=3.2* \
       build-essential=12.8* \
       ca-certificates=* \
       curl=* \
       fakeroot=* \
       git \
       libgmp-dev=2:6.* \
       liblua5.3-dev=5.3.3* \
       pkg-config=0.29.1* \
       zlib1g-dev=1:1.2.11.* \
  && rm -rf /var/lib/apt/lists/* \
  && ln -s /opt/ghc/bin/ghc-8.8.3 /usr/bin/ghc \
  && ln -s /opt/cabal/bin/cabal-3.2 /usr/bin/cabal
# close(ubuntu-local)

COPY cabal.root.config /root/.cabal/config
RUN  cabal --version \
  && ghc --version \
  && cabal new-update

# Builder ######################################################################
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
RUN test -n "$without_crossref" || \
    printf "extra-packages: pandoc-crossref\n" > cabal.project.local;
RUN cabal new-update \
  && cabal new-build \
      --disable-tests \
      --jobs \
      . pandoc-citeproc \
      $(test -n "$without_crossref" || printf pandoc-crossref)

RUN find dist-newstyle \
         -name 'pandoc*' -type f -perm -u+x \
         -exec cp '{}' /usr/local/bin/ ';'

# Cabal's exec stripping doesn't seem to work reliably, let's do it here.
RUN strip /usr/local/bin/pandoc*

# Core #########################################################################
FROM ubuntu:focal AS ubuntu-core
ARG pandoc_version=edge
LABEL maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.author "John MacFarlane"
LABEL org.pandoc.version "$pandoc_version"

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/pandoc"]

COPY --from=ubuntu-builder \
  /usr/local/bin/pandoc \
  /usr/local/bin/pandoc-citeproc \
  /usr/local/bin/

# begin(ubuntu-local)
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
# close(ubuntu-local)

# Crossref #####################################################################
FROM ubuntu-core AS ubuntu-crossref
COPY --from=ubuntu-builder \
  /usr/local/bin/pandoc-crossref \
  /usr/local/bin/
