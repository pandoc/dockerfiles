FROM alpine AS alpine-pandoc-haskell

RUN apk update \
  && apk add \
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

RUN cabal update \
  && cabal install cabal-install \
  && cp $HOME/.cabal/bin/cabal /usr/bin/

FROM alpine-pandoc-haskell AS alpine-pandoc-build
ARG pandoc_commit=master
ARG pandoc_citeproc_commit=master

WORKDIR /usr/src/
RUN git clone --branch=$pandoc_commit --depth=1 --quiet \
        https://github.com/jgm/pandoc
RUN git clone --branch=$pandoc_citeproc_commit --depth=1 --quiet \
        https://github.com/jgm/pandoc-citeproc

WORKDIR /usr/src/pandoc
# NOTE: --ghc-options -j +RTS -A128m -n2m -RTS, see:
# https://rybczak.net/2016/03/26/how-to-reduce-compilation-times-of-haskell-projects/
RUN cabal --version \
  && ghc --version \
  && cabal new-update \
  && cabal new-clean \
  && cabal new-configure \
           --flag embed_data_files \
           --flag bibutils \
           --constraint 'hslua +system-lua +pkg-config' \
           --ghc-options '-O1 -optc-Os -optl=-pthread -fPIC -j +RTS -A128m -n2m -RTS' \
           . pandoc-citeproc \
  && cabal new-build . pandoc-citeproc \
  && find dist-newstyle -name 'pandoc*' -type f -perm +400 -exec cp '{}' /usr/bin/ ';'

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
         libffi \
         lua5.3

WORKDIR /data
VOLUME ["/data"]
ENTRYPOINT ["pandoc"]
