#!/bin/sh
################################################################################
# Install pandoc latex packages: https://pandoc.org/MANUAL.html#creating-a-pdf #
################################################################################
# NOTE: search left hand side on CTAN to see for yourself:
#       graphicx  -> graphics
#       grffile   -> oberdiek
#       longtable -> tools
tlmgr install amsfonts \
              amsmath \
              babel \
              booktabs \
              fancyvrb \
              geometry \
              graphics \
              hyperref \
              iftex \
              listings \
              lm \
              lm-math \
              logreq \
              oberdiek \
              setspace \
              tools \
              ulem \
              unicode-math \
              xcolor \
              || exit 1

# Needed for when --highlight-style used with something other than pygments.
tlmgr install framed || exit 1

################################################################################
# Install extra packages for XeTex, LuaTex, and BibLaTex.                      #
################################################################################
tlmgr install bidi \
              csquotes \
              fontspec \
              luatex \
              lualatex-math \
              mathspec \
              microtype \
              pdftexcmds \
              polyglossia \
              selnolig \
              upquote \
              xecjk \
              xetex \
              || exit 1

# Make sure all reference backend options are installed
tlmgr install biber \
              biblatex \
              bibtex \
              natbib \
              || exit 1

# These packages were identified by the tests, they are likely dependencies of
# dependencies that are not encoded well.
tlmgr install footnotehyper \
              letltxmacro \
              xurl \
              || exit 1

################################################################################
# Trim down (possibly large amounts of) installed artifacts such as docs.      #
################################################################################
rm -rf /opt/texlive/texdir/texmf-dist/doc  \
       /opt/texlive/texdir/readme-html.dir \
       /opt/texlive/texdir/readme-txt.dir  \
       /opt/texlive/texdir/install-tl*
