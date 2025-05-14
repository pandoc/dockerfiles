#            _
#   _____  _| |_ _ __ __ _
#  / _ \ \/ / __| '__/ _` |
# |  __/>  <| |_| | | (_| |
#  \___/_/\_\\__|_|  \__,_|
#
ARG pandoc_version=edge
FROM pandoc/latex:${pandoc_version}-alpine

COPY common/extra/packages.txt /root/extra_packages.txt
COPY common/extra/requirements.txt /root/extra_requirements.txt

# uv is our preferred manager for Python packages
# but we keep pip for compatibility with downstream images
#
# NOTE: the uv package will be available in alpine 3.1
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV UV_TOOL_BIN_DIR=/usr/local/bin/
ENV UV_TOOL_DIR=/usr/local/share/uv/tools

RUN apk --no-cache add py-pip \
    && sed -e 's/ *#.*$//' -e '/^ *$/d' /root/extra_requirements.txt | \
       xargs -n1 uv tool install \
    && rm -f /root/extra_requirements.txt

RUN sed -e 's/ *#.*$//' -e '/^ *$/d' /root/extra_packages.txt | \
    xargs tlmgr install \
    && rm -f /root/extra_packages.txt

# Templates
ENV XDG_DATA_HOME=/usr/local/share
ARG PANDOC_DATA_DIR=$XDG_DATA_HOME/pandoc
ARG TEMPLATES_DIR=$PANDOC_DATA_DIR/templates
RUN mkdir -p $TEMPLATES_DIR

# eisvogel
ARG EISVOGEL_REPO=https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download
ARG EISVOGEL_VERSION=3.2.0
RUN wget -qO- ${EISVOGEL_REPO}/v${EISVOGEL_VERSION}/Eisvogel.tar.gz \
    | tar xz \
        --strip-components=1 \
        --one-top-level=${PANDOC_DATA_DIR} \
        Eisvogel-${EISVOGEL_VERSION}/eisvogel.latex \
        Eisvogel-${EISVOGEL_VERSION}/eisvogel.beamer

# Lua Filters
ARG LUA_FILTERS_REPO=https://github.com/pandoc/lua-filters/releases/download
ARG LUA_FILTERS_VERSION=2021-11-05
RUN wget -qO- ${LUA_FILTERS_REPO}/v${LUA_FILTERS_VERSION}/lua-filters.tar.gz \
    | tar xz \
        --strip-components=1 \
        --one-top-level=${PANDOC_DATA_DIR}

# tectonic
RUN apk --no-cache add tectonic
