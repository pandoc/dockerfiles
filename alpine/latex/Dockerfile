ARG base_tag="edge"
FROM pandoc/core:${base_tag}

# 1. Install `texlive-full` package, except for `texlive-doc`.  Run
#    `apk -R info texlive-full` to see dependencies.  However, to help reduce
#    the image size, instead of `texmf-dist-full` we choose `texmf-dist-most`.
#    Users seeking Chinese, Cyrillic, Greek, Japanese, or Korean should install
#    these packages (`texmf-dist-langchinese` for example), or install the
#    wrapper package `texmf-dist-lang`.  This saves approximately 800MB, so we
#    ask that users who need a specific language install it directly.
#
#    For an in-depth understanding of what options are available, see the
#    package specification here:
#
#        https://git.alpinelinux.org/aports/tree/community/texmf-dist/APKBUILD
#
# 2. Install `libsrvg`, pandoc uses `rsvg-convert` for working with svg images.
#
# NOTE: to maintainers, please keep this listing alphabetical.
RUN apk --no-cache add \
        gnupg \
        gzip \
        librsvg \
        perl \
        tar \
        wget

ENV PATH "/usr/local/texlive/2018/bin/x86_64-linuxmusl:${PATH}"

WORKDIR /root
COPY texlive.profile /root/texlive.profile
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
RUN mkdir -p install-tl \
  && cd install-tl \
  && tar --strip-components 1 -zvxf ../install-tl-unx.tar.gz \
  && ./install-tl --profile=/root/texlive.profile
RUN tlmgr install lm-math

WORKDIR /data
