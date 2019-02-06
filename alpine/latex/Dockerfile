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
# NOTE: piping to `grep Installing` to remedy issues on Travis CI builds.  A job
# will be terminated if no output for 10 minutes, as well as not being able to
# see apk progress is frustrating for users.  However, the texlive post-install
# scripts produce thousands of lines of output, which overflow the travis build
# log (max 10,000 lines).  This `grep Installing` is a hacky fix for both.
RUN apk --no-cache add librsvg \
                       texlive \
                       texlive-dvi \
                       texlive-luatex \
                       texlive-xetex \
                       texmf-dist-most \
                       xdvik \
                       | grep Installing
