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
RUN apk --no-cache add librsvg \
                       texlive \
                       texlive-dvi \
                       texlive-luatex \
                       texlive-xetex \
                       texmf-dist-most \
                       xdvik \
                       | grep 'Installing'
# NOTE: `grep 'Installing'` is to suppress latex post-install scripts from
# flooding the CI buffer.
