#            _
#   _____  _| |_ _ __ __ _
#  / _ \ \/ / __| '__/ _` |
# |  __/>  <| |_| | | (_| |
#  \___/_/\_\\__|_|  \__,_|
#
FROM pandoc/latex:3.6.4-alpine

# uv is our preferred manager for Python packages
# but we keep pip for compatibility with downstream images

RUN apk --no-cache add py-pip uv && \
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
RUN sed -e 's/ *#.*$//' -e '/^ *$/d' /root/extra_packages.txt | \
    xargs tlmgr install \
    && rm -f /root/extra_packages.txt

# Templates
ENV XDG_DATA_HOME=/usr/local/share
ENV PANDOC_DATA_HOME=${XDG_DATA_HOME}/pandoc
ENV PANDOC_TEMPLATES_DIR=${PANDOC_DATA_HOME}/templates
RUN mkdir -p ${PANDOC_TEMPLATES_DIR}

# eisvogel
ARG EISVOGEL_REPO=https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download
ARG EISVOGEL_VERSION=3.2.0
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
RUN apk --no-cache add tectonic
