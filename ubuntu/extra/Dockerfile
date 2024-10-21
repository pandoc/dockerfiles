#            _
#   _____  _| |_ _ __ __ _
#  / _ \ \/ / __| '__/ _` |
# |  __/>  <| |_| | | (_| |
#  \___/_/\_\\__|_|  \__,_|
#
ARG base_image_tag=edge-ubuntu
FROM pandoc/latex:$base_image_tag

COPY common/extra/packages.txt /root/extra_packages.txt
COPY common/extra/requirements.txt /root/extra_requirements.txt

# The option `--break-system-packages` sounds bad but this is not
# really a problem here because we are not using Python debian packages
# anyway.
RUN apt-get -q --no-allow-insecure-repositories update \
  && apt-get install --assume-yes --no-install-recommends python3-pip \
  && pip3 install -r /root/extra_requirements.txt --break-system-packages \
  && rm -f /root/extra_requirements.txt

RUN sed -e 's/ *#.*$//' -e '/^ *$/d' /root/extra_packages.txt | \
    xargs tlmgr install \
  && rm -f /root/extra_packages.txt

# Templates
#
ENV XDG_DATA_HOME=/usr/local/share
ARG PANDOC_DATA_DIR=$XDG_DATA_HOME/pandoc
ARG TEMPLATES_DIR=$PANDOC_DATA_DIR/templates
RUN mkdir -p $TEMPLATES_DIR

# eisvogel
ARG EISVOGEL_REPO=https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template
ARG EISVOGEL_VERSION=2.4.2
RUN wget ${EISVOGEL_REPO}/${EISVOGEL_VERSION}/eisvogel.tex \
        -O ${TEMPLATES_DIR}/eisvogel.latex

# Lua Filters
ARG LUA_FILTERS_REPO=https://github.com/pandoc/lua-filters/releases/download
ARG LUA_FILTERS_VERSION=v2021-11-05
RUN wget ${LUA_FILTERS_REPO}/${LUA_FILTERS_VERSION}/lua-filters.tar.gz \
    && tar xzf lua-filters.tar.gz \
        --strip-components=1 \
        --one-top-level=$PANDOC_DATA_DIR \
    && rm -f lua-filters.tar.gz

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
