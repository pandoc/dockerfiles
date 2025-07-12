#            _
#   _____  _| |_ _ __ __ _
#  / _ \ \/ / __| '__/ _` |
# |  __/>  <| |_| | | (_| |
#  \___/_/\_\\__|_|  \__,_|
#
FROM pandoc/latex:3.7.0.2-ubuntu

# uv is our preferred manager for Python packages
# but we keep pip for compatibility with downstream images
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV UV_TOOL_BIN_DIR=/usr/local/bin/
ENV UV_TOOL_DIR=/usr/local/share/uv/tools

RUN apt-get -q --no-allow-insecure-repositories update && \
    apt-get install --assume-yes --no-install-recommends python3-pip && \
    uv tool install 'pandoc-codeblock-include==1.1.*' && \
    uv tool install 'pandoc-latex-environment==1.2.*' && \
    uv tool install 'pandoc-include==1.4.*'

RUN tlmgr install \
        abstract \
        adjustbox \
        awesomebox \
        babel-german \
        background \
        beamertheme-metropolis \
        bidi \
        catchfile \
        cm-super \
        collectbox \
        csquotes \
        draftwatermark \
        enumitem \
        environ \
        environ \
        etoolbox \
        everypage \
        filehook \
        fontawesome5 \
        footmisc \
        footnotebackref \
        framed \
        fvextra \
        hardwrap \
        incgraph \
        koma-script \
        letltxmacro \
        lineno \
        listingsutf8 \
        ly1 \
        mdframed \
        mweights \
        needspace \
        pagecolor \
        pgf \
        pgfopts \
        sectsty \
        sourcecodepro \
        sourcesanspro \
        sourceserifpro \
        tcolorbox \
        tcolorbox \
        tikzfill \
        titlesec \
        titling \
        transparent \
        trimspaces \
        ucharcat \
        ulem \
        unicode-math \
        upquote \
        xecjk \
        xltxtra \
        xurl \
        zref

# Templates
#
ENV PANDOC_DATA_HOME=/usr/local/share/pandoc
ENV PANDOC_TEMPLATES_DIR=${PANDOC_DATA_HOME}/templates
RUN mkdir -p ${PANDOC_TEMPLATES_DIR}

# eisvogel
ARG EISVOGEL_REPO=https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download
RUN wget -qO- ${EISVOGEL_REPO}/v3.2.0/Eisvogel.tar.gz \
    | tar xz \
        --strip-components=1 \
        --one-top-level=${PANDOC_TEMPLATES_DIR} \
        Eisvogel-3.2.0/eisvogel.latex \
        Eisvogel-3.2.0/eisvogel.beamer

# Lua Filters
ARG LUA_FILTERS_REPO=https://github.com/pandoc/lua-filters/releases/download
ARG LUA_FILTERS_VERSION=2021-11-05
RUN wget -qO- ${LUA_FILTERS_REPO}/v${LUA_FILTERS_VERSION}/lua-filters.tar.gz \
    | tar xz \
        --strip-components=1 \
        --one-top-level=${PANDOC_DATA_HOME}

# tectonic
ARG TARGETARCH
ARG TECTONIC_REPO=https://github.com/tectonic-typesetting/tectonic/releases/download
ARG TECTONIC_VERSION=0.15.0
RUN <<EOF
set -ex;
case "$TARGETARCH" in
    (amd64)
        TECTONIC_ARCH='x86_64';
        TECTONIC_CLIB='gnu';
        ;;
    (arm64)
        TECTONIC_ARCH='aarch64' ;
        TECTONIC_CLIB='musl';
        ;;
    (*)
        printf 'unsupported target arch for tectonic: %s\n' "$TARGETARCH";
        exit 1 ;
        ;;
esac
TECTONIC_TARBALL_FMT='tectonic-%s-%s-unknown-linux-%s.tar.gz'
TECTONIC_TARBALL="$(printf "$TECTONIC_TARBALL_FMT" \
    "${TECTONIC_VERSION}" "${TECTONIC_ARCH}" "${TECTONIC_CLIB}" \
)"
wget ${TECTONIC_REPO}/tectonic%40${TECTONIC_VERSION}/${TECTONIC_TARBALL}
tar xzf ${TECTONIC_TARBALL} -C /usr/local/bin/
rm -f ${TECTONIC_TARBALL}
EOF
