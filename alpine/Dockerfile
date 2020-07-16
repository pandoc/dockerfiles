# Base #########################################################################
FROM alpine:3.12 AS alpine-builder-base
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
        lua5.3-dev \
        pkgconfig \
        zlib-dev

COPY cabal.root.config /root/.cabal/config
RUN cabal --version \
  && ghc --version \
  && cabal new-update

# Builder ######################################################################
FROM alpine-builder-base as alpine-builder
ARG pandoc_commit=master
RUN git clone --branch=$pandoc_commit --depth=1 --quiet \
  https://github.com/jgm/pandoc /usr/src/pandoc

COPY ./alpine/freeze/pandoc-$pandoc_commit.project.freeze \
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
FROM alpine:3.12 AS alpine-core
ARG pandoc_version=edge
LABEL maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.author "John MacFarlane"
LABEL org.pandoc.version "$pandoc_version"

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/pandoc"]

COPY --from=alpine-builder \
  /usr/local/bin/pandoc \
  /usr/local/bin/pandoc-citeproc \
  /usr/local/bin/

# Reinstall any system packages required for runtime.
RUN apk --no-cache add \
        gmp \
        libffi \
        lua5.3 \
        lua5.3-lpeg

# Crossref #####################################################################
FROM alpine-core AS alpine-crossref
COPY --from=alpine-builder \
  /usr/local/bin/pandoc-crossref \
  /usr/local/bin/
