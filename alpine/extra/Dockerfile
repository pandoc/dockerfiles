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

# The option `--break-system-packages` sounds bad but this is not
# really a problem here because we are not using Python apk packages
# anyway.
RUN  apk --no-cache add py-pip \
  && pip3 install -r /root/extra_requirements.txt --break-system-packages \
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
ARG EISVOGEL_REPO=https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template
ARG EISVOGEL_VERSION=2.5.0
RUN wget ${EISVOGEL_REPO}/${EISVOGEL_VERSION}/eisvogel.tex \
    -O ${TEMPLATES_DIR}/eisvogel.latex

# Lua filters
ARG LUA_FILTERS_REPO=https://github.com/pandoc/lua-filters/releases/download
ARG LUA_FILTERS_VERSION=v2021-11-05
RUN wget ${LUA_FILTERS_REPO}/${LUA_FILTERS_VERSION}/lua-filters.tar.gz \
    && tar xzf lua-filters.tar.gz \
           --strip-components=1 \
           --one-top-level=$PANDOC_DATA_DIR \
    && rm -f lua-filters.tar.gz

# tectonic
RUN apk --no-cache add tectonic
