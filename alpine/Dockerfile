FROM alpine AS alpine-core-haskell

RUN apk --no-cache add \
        alpine-sdk \
        bash \
        ca-certificates \
        cabal \
        fakeroot \
        ghc \
        git \
        gmp-dev \
        icu \
        icu-dev \
        lua5.3-dev \
        pkgconfig \
        zlib-dev

WORKDIR /root/.config
COPY cabal.config /root/.cabal/config

RUN cabal update \
  && cabal install cabal-install \
  && cp $HOME/.cabal/bin/cabal /usr/bin/

ARG pandoc_commit=master

# Install pandoc dependencies. New-style cabal commands make it difficult
# to cache build dependencies, which is why we fall back to v1 builds.
WORKDIR /usr/src/
RUN git clone --branch=$pandoc_commit --depth=1 --quiet \
        https://github.com/jgm/pandoc \
  && cd pandoc \
  && cabal v1-install \
           --only-dependencies \
           --constraint 'hslua +system-lua +pkg-config' \
           --flag embed_data_files \
  && cd .. \
  && rm -rf pandoc

# If we clone pandoc-citeproc and install its dependencies, then this
# will also install pandoc. That'd take a long time, and would
# ultimately be futile, as we'll be reinstalling pandoc later anyway.
# That's why we manually install missing dependencies. Yes I know, I
# don't like it either.
RUN cabal v1-install \
          hs-bibutils \
          setenv\<0.2 \
          text-icu \
          xml-conduit\<1.9 \
          yaml


FROM alpine-core-haskell AS alpine-pandoc-build
ARG pandoc_commit=master
ARG pandoc_citeproc_commit=master

WORKDIR /usr/src/
RUN git clone --branch=$pandoc_commit --depth=1 --quiet \
        https://github.com/jgm/pandoc \
  && cd pandoc \
  && cabal v1-configure \
           --flag embed_data_files \
           --constraint 'hslua +system-lua +pkg-config' \
  && cabal v1-build \
  && cabal v1-copy \
  && cabal v1-register \
  && cd ..

RUN git clone --branch=$pandoc_citeproc_commit --depth=1 --quiet \
        https://github.com/jgm/pandoc-citeproc \
  && cd pandoc-citeproc \
  && cabal v1-configure \
           --flag embed_data_files \
           --flag bibutils \
  && cabal v1-build \
  && cabal v1-copy \
  && cabal v1-register \
  && cd ..

RUN find /root/.cabal/bin -name 'pandoc*' -type f -perm +400 -exec cp '{}' /usr/bin/ ';'

RUN strip /usr/bin/pandoc /usr/bin/pandoc-citeproc


FROM alpine AS alpine-pandoc
ARG pandoc_commit=master
ARG pandoc_citeproc_commit=master
LABEL maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.author "John MacFarlane"
LABEL org.pandoc.version "$pandoc_commit"
LABEL org.pandoc.pandoc-citeproc.version "$pandoc_citeproc_commit"

COPY --from=alpine-pandoc-build /usr/bin/pandoc* /usr/bin/
RUN apk update \
  && apk add \
         gmp \
         icu \
         libffi \
         lua5.3

WORKDIR /data
VOLUME ["/data"]
ENTRYPOINT ["pandoc"]
