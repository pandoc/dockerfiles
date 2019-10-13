FROM alpine AS pandoc-builder

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

# Install newer cabal-install version
COPY cabal.root.config /root/.cabal/config
RUN cabal v2-update \
    && cabal v2-install cabal-install
# Make the new `cabal` available for the remainder of the build.
ENV PATH="/root/.cabal/bin:${PATH}"

# Get sources and build /usr/src/cabal.project file.
ARG pandoc_commit=master
WORKDIR /usr/src
COPY common/define_cabal_project_and_gather_sources.sh .

# NOTE: make calling script is kept with building / installing, otherwise Docker
# will cache things and we don't want that in this scenario.
# NOTE: this will be cabal 3+, meaning `v2-cmd` / `new-cmd` are now just `cmd`.
RUN ./define_cabal_project_and_gather_sources.sh ${pandoc_commit} \
    && cabal --version \
    && ghc --version \
    && cabal update \
    && cabal install \
             pandoc pandoc-citeproc pandoc-crossref \
             --installdir=/root/.cabal/bin \
             --install-method=copy \
             --flag embed_data_files \
             --flag bibutils \
             --constraint 'hslua +system-lua +pkg-config'

FROM pandoc-builder AS pandoc-binaries
# Build artifacts we seek are in /root/.cabal/bin.
RUN cp /root/.cabal/bin/pandoc* /usr/local/bin/ && strip /usr/local/bin/pandoc*

FROM alpine AS alpine-pandoc
ARG pandoc_commit=master

LABEL maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.maintainer='Albert Krewinkel <albert+pandoc@zeitkraut.de>'
LABEL org.pandoc.author "John MacFarlane"
LABEL org.pandoc.version "$pandoc_commit"

COPY --from=pandoc-binaries /usr/local/bin/pandoc* /usr/local/bin/
RUN apk add --no-cache \
         gmp \
         libffi \
         lua5.3 \
         lua5.3-lpeg

WORKDIR /data
ENTRYPOINT ["pandoc"]
