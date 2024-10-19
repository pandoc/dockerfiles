ARG base_image_tag=edge-alpine
FROM pandoc/core:$base_image_tag

# NOTE: to maintainers, please keep this listing alphabetical.
RUN apk --no-cache add \
        curl \
        fontconfig \
        freetype \
        gnupg \
        gzip \
        perl \
        tar \
        wget \
        xz

# TeXLive binaries location
ARG texlive_bin="/opt/texlive/texdir/bin"

# Modify PATH environment variable, prepending TexLive bin directory
ENV PATH="${texlive_bin}/default:${PATH}"

# Installer scripts and config
COPY common/latex/texlive.profile    /root/texlive.profile
COPY common/latex/install-texlive.sh /root/install-texlive.sh
COPY common/latex/packages.txt       /root/packages.txt

# TeXLive version to install (leave empty to use the latest version).
ARG texlive_version=

# TeXLive mirror URL (leave empty to use the default mirror).
ARG texlive_mirror_url=

# The architecture suffix may vary based on different distributions,
# particularly for musl libc based distrubions, like Alpine linux,
# where the suffix is linuxmusl
RUN ARCH="$(uname -m)" && \
    TEXLIVE_ARCH="${ARCH}-linuxmusl" && \
    mkdir -p ${texlive_bin} && \
    ln -sf "${texlive_bin}/${TEXLIVE_ARCH}" "${texlive_bin}/default" && \
# Request musl precompiled binary access
    echo "binary_${ARCH}-linuxmusl 1" >> /root/texlive.profile && \
    ( \
     [ -z "$texlive_version"    ] || printf '-t\n%s\n"' "$texlive_version"; \
     [ -z "$texlive_mirror_url" ] || printf '-m\n%s\n' "$texlive_mirror_url" \
    ) | xargs /root/install-texlive.sh && \
    sed -e 's/ *#.*$//' -e '/^ *$/d' /root/packages.txt | \
        xargs tlmgr install && \
    rm -f /root/texlive.profile \
          /root/install-texlive.sh \
          /root/packages.txt && \
    TERM=dumb luaotfload-tool --update && \
    chmod -R o+w /opt/texlive/texdir/texmf-var

WORKDIR /data
